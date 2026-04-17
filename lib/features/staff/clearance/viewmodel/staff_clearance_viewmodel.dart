import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/models/clearance_step.dart';
import 'package:student_clearance_tracker/core/repositories/academic_period_repository.dart';
import 'package:student_clearance_tracker/core/repositories/clearance_repository.dart';

class StaffClearanceViewModel extends ChangeNotifier {
  final _clearanceRepo = ClearanceRepository();
  final _periodRepo = AcademicPeriodRepository();

  List<ClearanceStep> _allSteps = [];
  int? _periodId;

  // UI State
  bool isLoading = true;
  bool isSaving = false;
  String? error;
  String _search = '';

  final Map<String, List<ClearanceStep>> filteredByStatus = {
    'pending': [], 'flagged': [], 'signed': [],
  };
  final Map<String, int> statusCounts = {
    'pending': 0, 'flagged': 0, 'signed': 0,
  };
  final Map<int, bool> prereqCache = {};

  Future<void> loadPeriodThenSteps(int? officeId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final period = await _periodRepo.getCurrent();
      _periodId = period?.id;
      await loadSteps(officeId, showLoading: false);
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSteps(int? officeId, {bool showLoading = true}) async {
    if (officeId == null || _periodId == null) {
      _allSteps = [];
      prereqCache.clear();
      _recompute();
      isLoading = false;
      notifyListeners();
      return;
    }

    if (showLoading) {
      isLoading = true;
      error = null;
      notifyListeners();
    }

    try {
      final steps = await _clearanceRepo.getByOffice(officeId, _periodId!);

      // Check prerequisites concurrently
      final prereqFutures = <int, Future<bool>>{};
      for (final step in steps.where((s) => s.isPending)) {
        prereqFutures[step.id] = _clearanceRepo.canOfficeSign(
          studentId: step.studentId,
          officeId: officeId,
          academicPeriodId: _periodId!,
        );
      }

      final prereqResults = await Future.wait(
        prereqFutures.entries.map((e) async => MapEntry(e.key, await e.value)),
      );

      _allSteps = steps;
      prereqCache.clear();
      prereqCache.addEntries(prereqResults);
      _recompute();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void updateSearch(String query) {
    _search = query;
    _recompute();
    notifyListeners();
  }

  void _recompute() {
    final q = _search.trim().toLowerCase();
    bool matchesSearch(ClearanceStep step) {
      if (q.isEmpty) return true;
      final name = (step.studentName ?? '').toLowerCase();
      final no = (step.studentNo ?? '').toLowerCase();
      return name.contains(q) || no.contains(q);
    }

    for (final status in ['pending', 'flagged', 'signed']) {
      final matchingSteps = _allSteps
          .where((s) => s.status == status)
          .where(matchesSearch)
          .toList(growable: false);

      filteredByStatus[status] = matchingSteps;
      statusCounts[status] = matchingSteps.length;
    }
  }

  Future<bool> signStep(ClearanceStep step, String updatedBy) async {
    isSaving = true;
    notifyListeners();
    try {
      await _clearanceRepo.updateStatus(
        stepId: step.id,
        status: 'signed',
        updatedBy: updatedBy,
      );
      await loadSteps(step.officeId, showLoading: false);
      return true;
    } catch (e) {
      error = 'Failed to sign: $e';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> flagStep(ClearanceStep step, String updatedBy, String remarks) async {
    isSaving = true;
    notifyListeners();
    try {
      await _clearanceRepo.updateStatus(
        stepId: step.id,
        status: 'flagged',
        updatedBy: updatedBy,
        remarks: remarks,
      );
      await loadSteps(step.officeId, showLoading: false);
      return true;
    } catch (e) {
      error = 'Failed to flag: $e';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}