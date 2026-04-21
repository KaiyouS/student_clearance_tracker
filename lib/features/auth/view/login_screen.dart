import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/features/auth/view/widgets/email_input_field.dart';
import 'package:student_clearance_tracker/features/auth/view/widgets/login/login_actions.dart';
import 'package:student_clearance_tracker/features/auth/view/widgets/login/login_card.dart';
import 'package:student_clearance_tracker/features/auth/view/widgets/login/login_header.dart';
import 'package:student_clearance_tracker/features/auth/view/widgets/password_input_field.dart';
import 'package:student_clearance_tracker/features/auth/viewmodel/login_viewmodel.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: const _LoginScreenContent(),
    );
  }
}

class _LoginScreenContent extends StatefulWidget {
  const _LoginScreenContent();

  @override
  State<_LoginScreenContent> createState() => _LoginScreenContentState();
}

class _LoginScreenContentState extends State<_LoginScreenContent> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final vm = context.read<LoginViewModel>();
    final destinationRoute = await vm.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (destinationRoute != null && mounted) {
      context.go(destinationRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginViewModel>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: LoginCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const LoginHeader(),
              const SizedBox(height: 32),
              EmailInputField(controller: _emailController),
              const SizedBox(height: 16),
              PasswordInputField(
                controller: _passwordController,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _handleLogin(),
              ),
              const SizedBox(height: 8),
              LoginActions(
                isLoading: vm.isLoading,
                errorMessage: vm.errorMessage,
                onSignIn: _handleLogin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
