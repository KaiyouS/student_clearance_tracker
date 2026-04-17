import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/models/office_staff.dart';
import 'package:student_clearance_tracker/core/repositories/staff_repository.dart';
import 'package:student_clearance_tracker/core/repositories/user_profile_repository.dart';

class StaffViewModel extends ChangeNotifier {
  final _repo = StaffRepository();
  final _profileRepo = UserProfileRepository();

  List<OfficeStaff> _allStaff = [];
  List<OfficeStaff> filteredStaff = [];

  bool isLoading = true;
  bool isSaving = false;
  String? errorMessage;
  String searchQuery = '';

  Future<void> loadStaff() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _allStaff = await _repo.getAll();
      _applySearchFilter();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    searchQuery = query;
    _applySearchFilter();
    notifyListeners();
  }

  void _applySearchFilter() {
    if (searchQuery.isEmpty) {
      filteredStaff = List.from(_allStaff);
    } else {
      final q = searchQuery.toLowerCase();
      filteredStaff = _allStaff.where((s) {
        return s.fullName.toLowerCase().contains(q) ||
               s.employeeNo.toLowerCase().contains(q);
      }).toList();
    }
  }

  Future<bool> createStaff(Map<String, dynamic> data) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _repo.create(
        email: data['email'],
        employeeNo: data['employee_no'],
        firstName: data['first_name'],
        middleName: data['middle_name'].isEmpty ? null : data['middle_name'],
        lastName: data['last_name'],
        officeIds: List<int>.from(data['office_ids']),
      );
      await loadStaff();
      return true;
    } catch (e) {
      errorMessage = 'Failed to create staff: $e';
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStaff(String id, Map<String, dynamic> data) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _repo.update(
        id: id,
        employeeNo: data['employee_no'],
        firstName: data['first_name'],
        middleName: data['middle_name'].isEmpty ? null : data['middle_name'],
        lastName: data['last_name'],
        officeIds: List<int>.from(data['office_ids']),
      );
      await loadStaff();
      return true;
    } catch (e) {
      errorMessage = 'Failed to update staff: $e';
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteStaff(String id) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _repo.delete(id);
      await loadStaff();
      return true;
    } catch (e) {
      errorMessage = 'Failed to delete staff: $e';
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStatus(String id, String newStatus) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _profileRepo.updateStatus(id, newStatus);
      await loadStaff();
      return true;
    } catch (e) {
      errorMessage = 'Failed to update status: $e';
      isSaving = false;
      notifyListeners();
      return false;
    }
  }
}