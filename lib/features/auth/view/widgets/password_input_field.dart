import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class PasswordInputField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final String? Function(String?)? validator;

  const PasswordInputField({
    super.key,
    required this.controller,
    this.labelText = 'Password',
    this.prefixIcon = PhosphorIconsLight.lock,
    this.textInputAction,
    this.onFieldSubmitted,
    this.validator,
  });

  @override
  State<PasswordInputField> createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.labelText,
        prefixIcon: PhosphorIcon(widget.prefixIcon),
        suffixIcon: IconButton(
          icon: PhosphorIcon(
            _obscureText ? PhosphorIconsLight.eyeSlash : PhosphorIconsLight.eye,
          ),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
      ),
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      validator: widget.validator,
    );
  }
}
