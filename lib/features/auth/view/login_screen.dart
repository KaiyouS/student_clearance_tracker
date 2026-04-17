import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/theme/app_dimensions.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    final vm = context.read<LoginViewModel>();
    final destinationRoute = await vm.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (destinationRoute != null && mounted) {
      context.go(destinationRoute);
    }
  }

  Future<void> _handleGoogleLogin() async {
    final vm = context.read<LoginViewModel>();
    final destinationRoute = await vm.loginWithGoogle();
    if (destinationRoute != null && mounted) {
      context.go(destinationRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginViewModel>();
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Scaffold(
      backgroundColor: isMobile
          ? Theme.of(context).colorScheme.surfaceContainer
          : Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: LoginCard(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const LoginHeader(),
                    const SizedBox(height: AppDimensions.xl),
                    EmailInputField(controller: _emailController),
                    const SizedBox(height: AppDimensions.md),
                    PasswordInputField(
                      controller: _passwordController,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleLogin(),
                      validator: (value) {
                        final password = value?.trim() ?? '';
                        if (password.isEmpty) {
                          return 'Password is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimensions.xl),
                    LoginActions(
                      isLoading: vm.isLoading,
                      errorMessage: vm.errorMessage,
                      onSignIn: _handleLogin,
                    ),
                    const SizedBox(height: AppDimensions.xl * 3),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
