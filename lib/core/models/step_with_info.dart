import 'package:student_clearance_tracker/core/models/clearance_step.dart';

class StepWithInfo {
  final ClearanceStep step;
  final bool         isBlocked;   // prerequisites not yet signed
  final List<String> waitingFor;  // office names blocking this step
  final int          level;       // topological depth (0 = no prereqs)

  const StepWithInfo({
    required this.step,
    required this.isBlocked,
    required this.waitingFor,
    required this.level,
  });
}