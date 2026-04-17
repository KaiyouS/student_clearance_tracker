import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/features/admin/data/repositories/dashboard_repository.dart';

class DashboardViewModel extends ChangeNotifier {
  final _repo = DashboardRepository();

  DashboardStats? stats;
  bool isLoading = true;
  String? errorMessage;

  Future<void> loadStats() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      stats = await _repo.getStats();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}