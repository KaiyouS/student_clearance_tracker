import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/models/clearance_step.dart';
import 'package:student_clearance_tracker/core/models/step_with_info.dart';
import 'package:student_clearance_tracker/core/repositories/clearance_repository.dart';

class StepDetailViewModel extends ChangeNotifier {
  final ClearanceRepository _repo;
  final StepWithInfo stepWithInfo;

  List<Map<String, dynamic>> _logs = [];
  ClearanceStep? _step;
  bool _isLoading = true;

  StepDetailViewModel({required this.stepWithInfo, ClearanceRepository? repo})
    : _repo = repo ?? ClearanceRepository();

  List<Map<String, dynamic>> get logs => _logs;
  ClearanceStep get step => _step ?? stepWithInfo.step;
  bool get isLoading => _isLoading;
  bool get isBlocked => stepWithInfo.isBlocked;
  List<String> get waitingFor => stepWithInfo.waitingFor;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait<dynamic>([
        _repo.getStepById(stepWithInfo.step.id),
        _repo.getStepLogs(stepWithInfo.step.id),
      ]);

      _step = results[0] as ClearanceStep;
      _logs = results[1] as List<Map<String, dynamic>>;
    } catch (_) {
      // Keep fallback data from stepWithInfo when fetch fails.
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
