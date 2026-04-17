import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/models/clearance_step.dart';
import 'package:student_clearance_tracker/core/repositories/academic_period_repository.dart';
import 'package:student_clearance_tracker/core/repositories/clearance_repository.dart';

class AdminClearanceOverviewStats {
  final int total;
  final int complete;
  final int flagged;
  final int noClearance;

  const AdminClearanceOverviewStats({
    required this.total,
    required this.complete,
    required this.flagged,
    required this.noClearance,
  });

  const AdminClearanceOverviewStats.empty()
    : total = 0,
      complete = 0,
      flagged = 0,
      noClearance = 0;
}

class AdminClearanceViewModel extends ChangeNotifier {
  final _clearanceRepo = ClearanceRepository();
  final _periodRepo = AcademicPeriodRepository();

  List<Map<String, dynamic>> _overview = [];
  List<Map<String, dynamic>> _filtered = [];
  List<ClearanceStep> _selectedSteps = [];
  AdminClearanceOverviewStats _overviewStats =
      const AdminClearanceOverviewStats.empty();

  int? _currentPeriodId;
  String? _currentPeriodLabel;

  Map<String, dynamic>? _selectedStudent;

  String _search = '';
  String _statusFilter = 'all';

  bool _isLoading = true;
  bool _isLoadingSteps = false;
  bool _isSaving = false;
  bool _isGenerating = false;
  String? _error;
  String? _actionError;
  String? _actionSuccess;

  List<Map<String, dynamic>> get filtered => _filtered;
  List<ClearanceStep> get selectedSteps => _selectedSteps;
  AdminClearanceOverviewStats get overviewStats => _overviewStats;
  int? get currentPeriodId => _currentPeriodId;
  String? get currentPeriodLabel => _currentPeriodLabel;
  Map<String, dynamic>? get selectedStudent => _selectedStudent;
  String get statusFilter => _statusFilter;
  bool get isLoading => _isLoading;
  bool get isLoadingSteps => _isLoadingSteps;
  bool get isSaving => _isSaving;
  bool get isGenerating => _isGenerating;
  String? get error => _error;
  String? get actionError => _actionError;
  String? get actionSuccess => _actionSuccess;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _clearanceRepo.getAdminOverview(),
        _periodRepo.getCurrent(),
      ]);

      final period = results[1] as dynamic;
      final overview = results[0] as List<Map<String, dynamic>>;

      _overview = overview;
      _overviewStats = _computeOverviewStats(overview);
      _currentPeriodId = period?.id;
      _currentPeriodLabel = period?.label;
      _isLoading = false;

      _applyFilters(notify: false);
      notifyListeners();

      if (_selectedStudent != null) {
        await _loadSteps(_selectedStudent!['student_id']);
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectStudent(Map<String, dynamic> student) async {
    _selectedStudent = student;
    notifyListeners();
    await _loadSteps(student['student_id']);
  }

  void updateSearch(String value) {
    _search = value;
    _applyFilters();
  }

  void updateStatusFilter(String status) {
    _statusFilter = status;
    _applyFilters();
  }

  Future<bool> generateForStudent(String studentId, String name) async {
    _isSaving = true;
    _actionError = null;
    _actionSuccess = null;
    notifyListeners();

    try {
      final count = await _clearanceRepo.generateForStudent(studentId);
      _actionSuccess = count > 0
          ? 'Created $count clearance step${count != 1 ? 's' : ''} for $name.'
          : 'All clearance steps already exist for $name.';
      await load();
      return true;
    } catch (e) {
      _actionError = 'Failed to generate clearance: $e';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> generateForAll() async {
    _isGenerating = true;
    _actionError = null;
    _actionSuccess = null;
    notifyListeners();

    try {
      final count = await _clearanceRepo.generateForAllStudents();
      _actionSuccess =
          'Done. Created $count new clearance step${count != 1 ? 's' : ''} '
          'across all students.';
      await load();
      return true;
    } catch (e) {
      _actionError = 'Failed to generate clearance: $e';
      return false;
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  Future<bool> overrideStep(
    ClearanceStep step,
    String newStatus,
    String updatedBy,
  ) async {
    _isSaving = true;
    _actionError = null;
    _actionSuccess = null;
    notifyListeners();

    try {
      final isReset = newStatus == 'pending';
      if (isReset) {
        await _clearanceRepo.resetStep(step.id);
      } else {
        await _clearanceRepo.updateStatus(
          stepId: step.id,
          status: newStatus,
          updatedBy: updatedBy,
        );
      }

      if (_selectedStudent != null) {
        await _loadSteps(_selectedStudent!['student_id']);
      }
      await load();
      _actionSuccess = 'Step updated.';
      return true;
    } catch (e) {
      _actionError = 'Failed to update step: $e';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> flagWithRemark(
    ClearanceStep step,
    String updatedBy,
    String? remarks,
  ) async {
    _isSaving = true;
    _actionError = null;
    _actionSuccess = null;
    notifyListeners();

    try {
      await _clearanceRepo.updateStatus(
        stepId: step.id,
        status: 'flagged',
        updatedBy: updatedBy,
        remarks: remarks,
      );

      if (_selectedStudent != null) {
        await _loadSteps(_selectedStudent!['student_id']);
      }
      await load();
      _actionSuccess = 'Step flagged.';
      return true;
    } catch (e) {
      _actionError = 'Failed to flag step: $e';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> _loadSteps(String studentId) async {
    if (_currentPeriodId == null) return;

    _isLoadingSteps = true;
    notifyListeners();

    try {
      _selectedSteps = await _clearanceRepo.getByStudent(
        studentId,
        _currentPeriodId!,
      );
    } finally {
      _isLoadingSteps = false;
      notifyListeners();
    }
  }

  void _applyFilters({bool notify = true}) {
    final normalizedSearch = _search.trim().toLowerCase();

    _filtered = _overview.where((s) {
      final name = (s['full_name'] ?? '').toLowerCase();
      final matchSearch =
          normalizedSearch.isEmpty || name.contains(normalizedSearch);

      final status = s['clearance_status'] ?? 'incomplete';
      final matchStatus = _statusFilter == 'all' || status == _statusFilter;

      return matchSearch && matchStatus;
    }).toList(growable: false);

    if (notify) {
      notifyListeners();
    }
  }

  AdminClearanceOverviewStats _computeOverviewStats(
    List<Map<String, dynamic>> data,
  ) {
    var complete = 0;
    var flagged = 0;
    var noClearance = 0;

    for (final student in data) {
      if (student['clearance_status'] == 'complete') {
        complete++;
      }
      if ((student['flagged_steps'] ?? 0) > 0) {
        flagged++;
      }
      if ((student['total_steps'] ?? 0) == 0) {
        noClearance++;
      }
    }

    return AdminClearanceOverviewStats(
      total: data.length,
      complete: complete,
      flagged: flagged,
      noClearance: noClearance,
    );
  }
}
