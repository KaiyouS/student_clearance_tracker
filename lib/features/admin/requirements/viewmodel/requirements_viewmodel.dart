import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/models/office.dart';
import 'package:student_clearance_tracker/core/models/program.dart';
import 'package:student_clearance_tracker/core/models/school.dart';
import 'package:student_clearance_tracker/core/repositories/office_repository.dart';
import 'package:student_clearance_tracker/core/repositories/program_repository.dart';
import 'package:student_clearance_tracker/core/repositories/school_repository.dart';
import 'package:student_clearance_tracker/features/admin/requirements/data/requirements_repository.dart';

class RequirementsViewModel extends ChangeNotifier {
  final _officeRepo = OfficeRepository();
  final _programRepo = ProgramRepository();
  final _schoolRepo = SchoolRepository();
  final _reqRepo = RequirementsRepository();

  List<Office> offices = [];
  List<Program> allPrograms = [];
  List<School> schools = [];
  Map<int, List<int?>> requirements = {};
  Office? selectedOffice;

  bool isLoading = true;
  bool isSaving = false;
  String? errorMessage;

  // ── Computed State ────────────────────────────────────────

  bool get appliesToAll {
    if (selectedOffice == null) return false;
    final reqs = requirements[selectedOffice!.id] ?? [];
    return reqs.contains(null);
  }

  Set<int> get assignedProgramIds {
    if (selectedOffice == null) return {};
    final reqs = requirements[selectedOffice!.id] ?? [];
    return reqs.whereType<int>().toSet();
  }

  Map<School, List<Program>> get programsBySchool {
    final map = <School, List<Program>>{};
    for (final school in schools) {
      final programs = allPrograms.where((p) => p.schoolId == school.id).toList();
      if (programs.isNotEmpty) map[school] = programs;
    }
    return map;
  }

  // Helper for the UI to know what string to show in the list badge
  String requirementSummary(Office office) {
    final reqs = requirements[office.id] ?? [];
    if (reqs.isEmpty) return 'No students';
    if (reqs.contains(null)) return 'All students';
    return '${reqs.length} program${reqs.length != 1 ? 's' : ''}';
  }

  // ── Actions ───────────────────────────────────────────────

  Future<void> loadData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _officeRepo.getAll(),
        _programRepo.getAll(),
        _schoolRepo.getAll(),
        _reqRepo.getAllRequirements(),
      ]);

      offices = results[0] as List<Office>;
      allPrograms = results[1] as List<Program>;
      schools = results[2] as List<School>;
      requirements = results[3] as Map<int, List<int?>>;

      if (selectedOffice != null) {
        selectedOffice = offices.firstWhere(
          (o) => o.id == selectedOffice!.id,
          orElse: () => offices.first,
        );
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectOffice(Office office) {
    selectedOffice = office;
    notifyListeners();
  }

  Future<bool> toggleAppliesToAll(bool value) async {
    if (selectedOffice == null) return false;
    
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (value) {
        await _reqRepo.setAppliesToAll(selectedOffice!.id);
      } else {
        await _reqRepo.clearRequirements(selectedOffice!.id);
      }
      await loadData();
      return true;
    } catch (e) {
      errorMessage = 'Failed to update: $e';
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleProgram(int programId, bool add) async {
    if (selectedOffice == null) return false;

    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (add) {
        await _reqRepo.addRequirement(selectedOffice!.id, programId);
      } else {
        await _reqRepo.removeRequirement(selectedOffice!.id, programId);
      }
      await loadData();
      return true;
    } catch (e) {
      errorMessage = 'Failed to update: $e';
      isSaving = false;
      notifyListeners();
      return false;
    }
  }
}