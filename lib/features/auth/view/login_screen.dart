import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:student_clearance_tracker/core/constants/app_assets.dart';
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
                    if (kIsWeb) SizedBox(height: AppDimensions.xl * 3),
                    if (!kIsWeb) ...[
                      SizedBox(height: AppDimensions.lg),
                      Row(
                        children: [
                          const Expanded(child: Divider(thickness: 1)),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Text(
                              'or',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider(thickness: 1)),
                        ],
                      ),
                      SizedBox(height: AppDimensions.lg),

                      GestureDetector(
                        onTap: vm.isLoading ? null : _handleGoogleLogin,
                        child: Opacity(
                          opacity: vm.isLoading ? 0.5 : 1.0,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusSm,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withValues(alpha: 0.4),
                                      spreadRadius: 2,
                                      blurRadius: 10,
                                      offset: Offset(0, 3),
                                    ),
                                  ]
                                ),
                                padding: const EdgeInsets.all(
                                  8,
                                ),
                                child: Image.asset(
                                  AppAssets.googleLogo,
                                  fit: BoxFit.contain,
                                ),
                              ),

                              const SizedBox(
                                height: 8,
                              ),
                              const Text(
                                'Google',
                                style: TextStyle(
                                  color: Colors
                                      .white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
