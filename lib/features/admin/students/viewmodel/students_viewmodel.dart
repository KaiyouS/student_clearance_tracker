import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/models/student.dart';
import 'package:student_clearance_tracker/core/repositories/student_repository.dart';
import 'package:student_clearance_tracker/core/repositories/user_profile_repository.dart';

class StudentsViewModel extends ChangeNotifier {
  final _repo = StudentRepository();
  final _profileRepo = UserProfileRepository();

  List<Student> _allStudents = [];
  List<Student> filteredStudents = [];

  bool isLoading = true;
  bool isSaving = false;
  String? errorMessage;
  String searchQuery = '';

  Future<void> loadStudents() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _allStudents = await _repo.getAll();
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
      filteredStudents = List.from(_allStudents);
    } else {
      final q = searchQuery.toLowerCase();
      filteredStudents = _allStudents.where((s) {
        return (s.profile?.fullName.toLowerCase().contains(q) ?? false) ||
               s.studentNo.toLowerCase().contains(q);
      }).toList();
    }
  }

  Future<bool> createStudent(Map<String, dynamic> data) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _repo.create(
        email: data['email'],
        studentNo: data['student_no'],
        firstName: data['first_name'],
        middleName: data['middle_name']?.isEmpty == true ? null : data['middle_name'],
        lastName: data['last_name'],
        programId: data['program_id'],
        yearLevel: data['year_level'],
      );
      await loadStudents();
      return true;
    } catch (e) {
      errorMessage = 'Failed to create student: $e';
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStudent(String id, Map<String, dynamic> data) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _repo.update(
        id: id,
        studentNo: data['student_no'],
        firstName: data['first_name'],
        middleName: data['middle_name']?.isEmpty == true ? null : data['middle_name'],
        lastName: data['last_name'],
        programId: data['program_id'],
        yearLevel: data['year_level'],
      );
      await loadStudents();
      return true;
    } catch (e) {
      errorMessage = 'Failed to update student: $e';
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
      await loadStudents();
      return true;
    } catch (e) {
      errorMessage = 'Failed to update status: $e';
      isSaving = false;
      notifyListeners();
      return false;
    }
  }
}