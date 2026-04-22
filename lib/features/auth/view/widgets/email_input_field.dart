import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class EmailInputField extends StatelessWidget {
  final TextEditingController controller;

  const EmailInputField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'Email',
        hintText: 'Email',
        prefixIcon: PhosphorIcon(PhosphorIconsLight.envelope),
      ),
      validator: (value) {
        final email = value?.trim() ?? '';
        if (email.isEmpty) {
          return 'Email is required';
        }

        final emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
        if (!emailPattern.hasMatch(email)) {
          return 'Enter a valid email';
        }

        return null;
      },
    );
  }
}
