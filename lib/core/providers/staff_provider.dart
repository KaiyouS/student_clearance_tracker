import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/models/office.dart';
import 'package:student_clearance_tracker/core/models/office_staff.dart';
import 'package:student_clearance_tracker/core/repositories/staff_repository.dart';

class StaffProvider extends ChangeNotifier {
  final _repo = StaffRepository();

  OfficeStaff? _profile;
  Office?      _selectedOffice;
  List<Office> _assignedOffices = [];
  bool         _isLoading       = true;

  OfficeStaff? get profile         => _profile;
  Office?      get selectedOffice  => _selectedOffice;
  List<Office> get assignedOffices => _assignedOffices;
  bool         get isLoading       => _isLoading;
  
  bool _initialized    =  false;
  bool get initialized => _initialized;

  Future<void> loadProfile(String userId) async {
    _initialized = true;
    _isLoading = true;
    notifyListeners();

    try {
      final staff   = await _repo.getById(userId);
      final officeIds = await _repo.getOfficeIds(userId);

      // Get full office objects
      final allOffices = await _repo.getAllOffices();
      final assigned   = allOffices
          .where((o) => officeIds.contains(o.id))
          .toList();

      _profile         = staff;
      _assignedOffices = assigned;
      _selectedOffice  = assigned.isNotEmpty ? assigned.first : null;
    } catch (_) {
      _assignedOffices = [];
      _selectedOffice  = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectOffice(Office office) {
    _selectedOffice = office;
    notifyListeners();
  }
}