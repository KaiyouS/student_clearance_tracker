import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/models/office.dart';
import 'package:student_clearance_tracker/core/repositories/office_repository.dart';

class OfficesViewModel extends ChangeNotifier {
  final _repo = OfficeRepository();

  List<Office> _allOffices = [];
  List<Office> filteredOffices = [];

  bool isLoading = true;
  String? errorMessage;
  String searchQuery = '';

  Future<void> loadOffices() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _allOffices = await _repo.getAll();
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
      filteredOffices = List.from(_allOffices);
    } else {
      final q = searchQuery.toLowerCase();
      filteredOffices = _allOffices.where((o) {
        return o.name.toLowerCase().contains(q) ||
            (o.description ?? '').toLowerCase().contains(q);
      }).toList();
    }
  }

  Future<bool> createOffice(String name, String? description) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    
    try {
      final newOffice = Office(id: 0, name: name, description: description);
      await _repo.create(newOffice);
      await loadOffices(); // reloads data and sets isLoading to false
      return true;
    } catch (e) {
      errorMessage = 'Failed to create office: $e';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateOffice(int id, String name, String? description) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final updatedOffice = Office(id: id, name: name, description: description);
      await _repo.update(id, updatedOffice);
      await loadOffices();
      return true;
    } catch (e) {
      errorMessage = 'Failed to update office: $e';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteOffice(int id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _repo.delete(id);
      await loadOffices();
      return true;
    } catch (e) {
      errorMessage = 'Failed to delete office: $e';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}