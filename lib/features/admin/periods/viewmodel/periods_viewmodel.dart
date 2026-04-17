import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/models/academic_period.dart';
import 'package:student_clearance_tracker/core/repositories/academic_period_repository.dart';

class PeriodsViewModel extends ChangeNotifier {
  final _repo = AcademicPeriodRepository();

  List<AcademicPeriod> periods = [];
  bool isLoading = true;
  bool isSaving = false;
  String? errorMessage;

  Future<void> loadPeriods() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      periods = await _repo.getAll();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPeriod(Map<String, dynamic> data) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _repo.create(
        AcademicPeriod(
          id: 0,
          label: data['label'],
          startDate: data['start_date'],
          endDate: data['end_date'],
          isCurrent: false,
        ),
      );
      await loadPeriods();
      return true;
    } catch (e) {
      errorMessage = 'Failed to create period: $e';
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePeriod(int id, Map<String, dynamic> data, bool isCurrent) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _repo.update(
        id,
        AcademicPeriod(
          id: id,
          label: data['label'],
          startDate: data['start_date'],
          endDate: data['end_date'],
          isCurrent: isCurrent,
        ),
      );
      await loadPeriods();
      return true;
    } catch (e) {
      errorMessage = 'Failed to update period: $e';
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePeriod(AcademicPeriod period) async {
    if (period.isCurrent) {
      errorMessage = 'Cannot delete the current period. Set another period as current first.';
      // We don't need to loadPeriods() here, just show the error
      notifyListeners(); 
      return false;
    }

    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _repo.delete(period.id);
      await loadPeriods();
      return true;
    } catch (e) {
      errorMessage = 'Failed to delete period: $e';
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> setCurrentPeriod(AcademicPeriod period) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _repo.setCurrent(period.id);
      await loadPeriods();
      return true;
    } catch (e) {
      errorMessage = 'Failed to set current period: $e';
      isSaving = false;
      notifyListeners();
      return false;
    }
  }
}