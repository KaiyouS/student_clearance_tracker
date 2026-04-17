import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/models/program.dart';
import 'package:student_clearance_tracker/core/models/school.dart';
import 'package:student_clearance_tracker/core/repositories/program_repository.dart';
import 'package:student_clearance_tracker/core/repositories/school_repository.dart';

class SchoolsViewModel extends ChangeNotifier {
  final _schoolRepo = SchoolRepository();
  final _programRepo = ProgramRepository();

  List<School> schools = [];
  List<Program> programs = [];
  School? selectedSchool;

  bool isLoadingSchools = true;
  bool isLoadingPrograms = false;
  bool isSaving = false;
  String? errorMessage;

  Future<void> loadSchools() async {
    isLoadingSchools = true;
    errorMessage = null;
    notifyListeners();

    try {
      schools = await _schoolRepo.getAll();
      
      // Re-select same school if it was selected and reload its programs
      if (selectedSchool != null) {
        selectedSchool = schools.firstWhere(
          (s) => s.id == selectedSchool!.id,
          orElse: () => schools.first,
        );
        await loadPrograms(selectedSchool!.id);
      } else {
        isLoadingSchools = false;
        notifyListeners();
      }
    } catch (e) {
      errorMessage = e.toString();
      isLoadingSchools = false;
      notifyListeners();
    }
  }

  Future<void> loadPrograms(int schoolId) async {
    isLoadingPrograms = true;
    programs = [];
    notifyListeners();

    try {
      programs = await _programRepo.getBySchool(schoolId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoadingSchools = false;
      isLoadingPrograms = false;
      notifyListeners();
    }
  }

  void selectSchool(School school) {
    selectedSchool = school;
    loadPrograms(school.id);
  }

  // ── School CRUD ───────────────────────────────────────────

  Future<bool> createSchool(Map<String, String?> data) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _schoolRepo.create(School(id: 0, name: data['name']!, description: data['description']));
      await loadSchools();
      return true;
    } catch (e) {
      errorMessage = 'Failed to create school: $e';
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSchool(int id, Map<String, String?> data) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _schoolRepo.update(id, School(id: id, name: data['name']!, description: data['description']));
      await loadSchools();
      return true;
    } catch (e) {
      errorMessage = 'Failed to update school: $e';
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSchool(int id) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _schoolRepo.delete(id);
      if (selectedSchool?.id == id) {
        selectedSchool = null;
        programs = [];
      }
      await loadSchools();
      return true;
    } catch (e) {
      errorMessage = 'Failed to delete school: $e';
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  // ── Program CRUD ──────────────────────────────────────────

  Future<bool> createProgram(Map<String, String?> data) async {
    if (selectedSchool == null) return false;
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _programRepo.create(Program(id: 0, name: data['name']!, schoolId: selectedSchool!.id));
      await loadPrograms(selectedSchool!.id);
      return true;
    } catch (e) {
      errorMessage = 'Failed to create program: $e';
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProgram(int id, Map<String, String?> data) async {
    if (selectedSchool == null) return false;
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _programRepo.update(id, Program(id: id, name: data['name']!, schoolId: selectedSchool!.id));
      await loadPrograms(selectedSchool!.id);
      return true;
    } catch (e) {
      errorMessage = 'Failed to update program: $e';
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProgram(int id) async {
    if (selectedSchool == null) return false;
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _programRepo.delete(id);
      await loadPrograms(selectedSchool!.id);
      return true;
    } catch (e) {
      errorMessage = 'Failed to delete program: $e';
      isSaving = false;
      notifyListeners();
      return false;
    }
  }
}