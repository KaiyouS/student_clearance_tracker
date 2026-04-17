import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/models/office.dart';
import 'package:student_clearance_tracker/core/repositories/office_repository.dart';
import 'package:student_clearance_tracker/features/admin/prerequisites/data/prerequisites_repository.dart';

class PrerequisitesViewModel extends ChangeNotifier {
  final _officeRepo = OfficeRepository(); // For getAll()
  final _prereqRepo = PrerequisitesRepository(); // For prereq specifics

  List<Office> allOffices = [];
  Map<int, List<Office>> prerequisites = {};
  Office? selectedOffice;

  bool isLoading = true;
  bool isSaving = false;
  String? errorMessage;

  Future<void> loadData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final offices = await _officeRepo.getAll();
      final prereqs = await _prereqRepo.getAllPrerequisites();
      
      allOffices = offices;
      prerequisites = prereqs;
      
      // Re-select the same office if it was selected before
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

  List<Office> prerequisitesFor(Office office) {
    return prerequisites[office.id] ?? [];
  }

  Future<bool> addPrerequisite(Office office, Office requires) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _prereqRepo.addPrerequisite(office.id, requires.id);
      await loadData();
      return true;
    } catch (e) {
      errorMessage = 'Failed to add prerequisite: $e';
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> removePrerequisite(Office office, Office requires) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _prereqRepo.removePrerequisite(office.id, requires.id);
      await loadData();
      return true;
    } catch (e) {
      errorMessage = 'Failed to remove prerequisite: $e';
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  // ── Business Logic: Cycle Detection & Validation ───────────

  bool _wouldCreateCycle(int officeId, int requiresOfficeId) {
    final visited = <int>{};
    return _reachable(requiresOfficeId, officeId, visited);
  }

  bool _reachable(int from, int target, Set<int> visited) {
    if (from == target) return true;
    if (visited.contains(from)) return false;
    visited.add(from);
    final prereqs = prerequisites[from] ?? [];
    return prereqs.any((p) => _reachable(p.id, target, visited));
  }

  Map<String, dynamic> getDisabledOfficesMap(Office targetOffice) {
    final disabledIds = <int>{};
    final disabledReasons = <int, String>{};

    for (final o in allOffices) {
      if (o.id == targetOffice.id) {
        disabledIds.add(o.id);
        disabledReasons[o.id] = 'An office cannot require itself.';
      } else if (prerequisitesFor(targetOffice).any((p) => p.id == o.id)) {
        disabledIds.add(o.id);
        disabledReasons[o.id] = 'Already a prerequisite.';
      } else if (_wouldCreateCycle(targetOffice.id, o.id)) {
        disabledIds.add(o.id);
        disabledReasons[o.id] =
            'Would create a cycle — "${o.name}" already depends on '
            '"${targetOffice.name}" directly or indirectly.';
      }
    }

    return {
      'ids': disabledIds,
      'reasons': disabledReasons,
    };
  }
}