import 'dart:math';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:student_clearance_tracker/main.dart';
import 'package:student_clearance_tracker/core/models/academic_period.dart';
import 'package:student_clearance_tracker/core/models/clearance_step.dart';
import 'package:student_clearance_tracker/core/models/step_with_info.dart';
import 'package:student_clearance_tracker/core/models/student.dart';
import 'package:student_clearance_tracker/core/models/user_profile.dart';
import 'package:student_clearance_tracker/core/repositories/academic_period_repository.dart';
import 'package:student_clearance_tracker/core/repositories/clearance_repository.dart';
import 'package:student_clearance_tracker/core/repositories/office_repository.dart';
import 'package:student_clearance_tracker/core/repositories/student_repository.dart';
import 'package:student_clearance_tracker/core/repositories/user_profile_repository.dart';

class InAppNotification {
  final String officeName;
  final String status;
  final DateTime time;

  InAppNotification({required this.officeName, required this.status})
    : time = DateTime.now();

  String get message => status == 'signed'
      ? '$officeName has signed your clearance ✅'
      : '$officeName has flagged your clearance ⚠️';
}

class StudentProvider extends ChangeNotifier {
  final _studentRepo = StudentRepository();
  final _clearanceRepo = ClearanceRepository();
  final _officeRepo = OfficeRepository();
  final _periodRepo = AcademicPeriodRepository();
  final _profileRepo = UserProfileRepository();

  // State
  UserProfile? _profile;
  Student? _student;
  AcademicPeriod? _currentPeriod;
  List<ClearanceStep> _steps = [];
  List<StepWithInfo> _stepsWithInfo = [];
  Map<int, List<int>> _prereqMap = {};
  int _signedSteps = 0;
  int _pendingSteps = 0;
  int _flaggedSteps = 0;

  // In-app notifications (for web banner + mobile)
  final List<InAppNotification> _notifications = [];

  // Realtime
  RealtimeChannel? _channel;

  bool _isLoading = true;
  String? _error;

  // ── Getters ───────────────────────────────────────────────
  UserProfile? get profile => _profile;
  Student? get student => _student;
  AcademicPeriod? get currentPeriod => _currentPeriod;
  List<StepWithInfo> get steps => UnmodifiableListView(_stepsWithInfo);
  List<InAppNotification> get notifications =>
      List.unmodifiable(_notifications);
  InAppNotification? get latestNotification =>
      _notifications.isEmpty ? null : _notifications.last;
  bool get hasNotifications => _notifications.isNotEmpty;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalSteps => _steps.length;
  int get signedSteps => _signedSteps;
  int get pendingSteps => _pendingSteps;
  int get flaggedSteps => _flaggedSteps;
  bool get isComplete => totalSteps > 0 && signedSteps == totalSteps;
  bool get hasSteps => totalSteps > 0;

  bool _initialized = false;
  bool get initialized => _initialized;

  void _applyStepSnapshot(List<ClearanceStep> steps) {
    _steps = steps;
    _signedSteps = steps.where((s) => s.isSigned).length;
    _pendingSteps = steps.where((s) => s.isPending).length;
    _flaggedSteps = steps.where((s) => s.isFlagged).length;
    _stepsWithInfo = _computeStepsWithInfo(steps, _prereqMap);
  }

  // ── Load ──────────────────────────────────────────────────
  Future<void> loadData(String userId) async {
    _initialized = true;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _profileRepo.getById(userId),
        _studentRepo.getById(userId),
        _periodRepo.getCurrent(),
        _officeRepo.getPrerequisiteMap(),
      ]);

      _profile = results[0] as UserProfile?;
      _student = results[1] as Student;
      _currentPeriod = results[2] as AcademicPeriod?;
      _prereqMap = results[3] as Map<int, List<int>>;

      if (_currentPeriod != null) {
        final steps = await _clearanceRepo.getByStudent(userId, _currentPeriod!.id);
        _applyStepSnapshot(steps);
      } else {
        _applyStepSnapshot(const <ClearanceStep>[]);
      }

      await _computeUnseenUpdates(userId);
      _subscribeToChanges(userId);

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // ── Realtime ──────────────────────────────────────────────
  int _unseenUpdates = 0;
  int get unseenUpdates => _unseenUpdates;

  // Called when clearance tab is tapped
  Future<void> markClearanceVisited() async {
    await _profileRepo.markClearanceVisited();
    _lastVisitedAt = DateTime.now().toUtc();
    _replaceChangedSteps(const <int>[]);
    _unseenUpdates = 0;
    notifyListeners();
  }

  void clearChangedSteps() {
    _replaceChangedSteps(const <int>[]);
    notifyListeners();
  }

  DateTime? _lastVisitedAt;
  final Set<int> _changedStepIds = <int>{};
  int _changedStepIdsVersion = 0;
  int get changedStepsVersion => _changedStepIdsVersion;

  bool wasStepChanged(int stepId) => _changedStepIds.contains(stepId);

  void _replaceChangedSteps(Iterable<int> ids) {
    final nextIds = ids.toSet();
    if (
      nextIds.length == _changedStepIds.length &&
      _changedStepIds.containsAll(nextIds)
    ) {
      return;
    }

    _changedStepIds
      ..clear()
      ..addAll(nextIds);
    _changedStepIdsVersion++;
  }
  
  Future<void> _computeUnseenUpdates(String userId) async {
    try {
      _lastVisitedAt = await _profileRepo.getClearanceLastVisited(userId);

      if (_lastVisitedAt == null) {
        _replaceChangedSteps(const <int>[]);
        _unseenUpdates = 0;
        return;
      }

      _replaceChangedSteps(
        _steps
            .where((s) => s.updatedAt != null && s.updatedAt!.isAfter(_lastVisitedAt!))
            .map((s) => s.id),
      );

      _unseenUpdates = _changedStepIds.length;
    } catch (_) {
      _replaceChangedSteps(const <int>[]);
      _unseenUpdates = 0;
    }
  }

  void _subscribeToChanges(String userId) {
    // Remove existing subscription if any
    if (_channel != null) {
      supabase.removeChannel(_channel!);
    }

    _channel = supabase
        .channel('student-steps-$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'clearance_steps',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'student_id',
            value: userId,
          ),
          callback: (payload) => _handleStepUpdate(payload, userId),
        )
        .subscribe();
  }
  
  // TODO: don't increment if user is already on the clearance screen
  void _handleStepUpdate(PostgresChangePayload payload, String userId) async {
    final newRecord = payload.newRecord;

    final stepId = newRecord['id'] as int?;
    final newStatus = newRecord['status'] as String?;

    if (stepId == null || newStatus == null) return;

    // Optional in-app banner: only for meaningful status changes
    if (newStatus == 'signed' || newStatus == 'flagged') {
      final idx = _steps.indexWhere((s) => s.id == stepId);
      final officeName = idx != -1 ? (_steps[idx].officeName ?? 'An office') : 'An office';

      _notifications.add(
        InAppNotification(
          officeName: officeName,
          status: newStatus,
        ),
      );
    }

    // Refresh full step list so the clearance cards update immediately
    if (_currentPeriod != null) {
      final steps = await _clearanceRepo.getByStudent(userId, _currentPeriod!.id);
      _applyStepSnapshot(steps);

      // Recompute unseen count from last visited timestamp
      await _computeUnseenUpdates(userId);
    }

    notifyListeners();
  }

  void dismissNotification(int index) {
    if (index >= 0 && index < _notifications.length) {
      _notifications.removeAt(index);
      notifyListeners();
    }
  }

  // ── Prerequisite chain computation ────────────────────────
  List<StepWithInfo> _computeStepsWithInfo(
    List<ClearanceStep> steps,
    Map<int, List<int>> prereqMap,
  ) {
    final stepOfficeIds = steps.map((s) => s.officeId).toSet();
    final officeToStep = {for (final s in steps) s.officeId: s};

    // Compute topological levels
    final levels = <int, int>{};
    bool changed = true;
    while (changed) {
      changed = false;
      for (final step in steps) {
        final oid = step.officeId;
        if (levels.containsKey(oid)) continue;

        // Only consider prerequisites that are also in this student's steps
        final prereqs = (prereqMap[oid] ?? [])
            .where(stepOfficeIds.contains)
            .toList();

        if (prereqs.isEmpty) {
          levels[oid] = 0;
          changed = true;
        } else if (prereqs.every(levels.containsKey)) {
          levels[oid] = prereqs.map((id) => levels[id]!).reduce(max) + 1;
          changed = true;
        }
      }
    }

    // Assign remaining steps (shouldn't happen in a valid DAG)
    for (final step in steps) {
      levels.putIfAbsent(step.officeId, () => 999);
    }

    // Build StepWithInfo list
    final result = steps.map((step) {
      final prereqs = (prereqMap[step.officeId] ?? [])
          .where(stepOfficeIds.contains)
          .toList();

      final waitingFor = <String>[];
      var isBlocked = false;

      for (final reqId in prereqs) {
        final reqStep = officeToStep[reqId];
        if (reqStep != null && !reqStep.isSigned) {
          isBlocked = true;
          if (reqStep.officeName != null) {
            waitingFor.add(reqStep.officeName!);
          }
        }
      }

      return StepWithInfo(
        step: step,
        isBlocked: isBlocked,
        waitingFor: waitingFor,
        level: levels[step.officeId] ?? 0,
      );
    }).toList();

    // Sort by level ascending, then by office name
    result.sort((a, b) {
      final levelCmp = a.level.compareTo(b.level);
      if (levelCmp != 0) return levelCmp;
      return (a.step.officeName ?? '').compareTo(b.step.officeName ?? '');
    });

    return result;
  }
  
  StepWithInfo? get nextActionableStep {
    try {
      return _stepsWithInfo.firstWhere(
        (s) => s.step.isPending && !s.isBlocked,
      );
    } catch (_) {
      return null;
    }
  }

  void setState(VoidCallback fn) {
    fn();
    notifyListeners();
  }

  @override
  void dispose() {
    if (_channel != null) supabase.removeChannel(_channel!);
    super.dispose();
  }
}
