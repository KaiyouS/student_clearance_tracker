import 'package:flutter/material.dart';
import 'package:student_clearance_tracker/core/models/program.dart';
import 'package:student_clearance_tracker/core/repositories/program_repository.dart';
import 'package:student_clearance_tracker/core/repositories/student_repository.dart';
import 'package:student_clearance_tracker/core/services/auth_service.dart';

class StudentOnboardingViewModel extends ChangeNotifier {
  final _programRepo = ProgramRepository();
  final _studentRepo = StudentRepository();
  final _authService = AuthService();

  bool _loadingPrograms = true;
  bool _submitting = false;
  String? _errorMessage;
  List<Program> _programs = const [];

  bool get loadingPrograms => _loadingPrograms;
  bool get submitting => _submitting;
  String? get errorMessage => _errorMessage;
  List<Program> get programs => _programs;

  String? get currentEmail => _authService.getCurrentUser()?.email;

  Future<void> initialize() async {
    _loadingPrograms = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _programs = await _programRepo.getAll();
    } catch (_) {
      _errorMessage = 'Unable to load programs right now.';
    } finally {
      _loadingPrograms = false;
      notifyListeners();
    }
  }

  Future<String?> completeOnboarding({
    required String studentNo,
    required String firstName,
    String? middleName,
    required String lastName,
    int? programId,
    int? yearLevel,
  }) async {
    _submitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = _authService.getCurrentUser();
      final email = user?.email;
      if (user == null || !_authService.isAllowedStudentEmail(email)) {
        await _authService.signOut();
        throw Exception('Use your addu.edu.ph Google account to continue.');
      }

      await _studentRepo.completeOnboarding(
        studentNo: studentNo,
        firstName: firstName,
        middleName: middleName,
        lastName: lastName,
        programId: programId,
        yearLevel: yearLevel,
      );

      return '/student/home';
    } catch (e) {
      final raw = e.toString();
      _errorMessage = raw.startsWith('Exception: ')
          ? raw.substring('Exception: '.length)
          : 'Failed to complete onboarding.';
      return null;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }
}
