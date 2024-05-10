import 'package:flutter/material.dart';

class InputToLoginSignUp extends StatelessWidget {
  final TextEditingController controller;
  final Icon icon;
  final String labelText;
  final String? errorText;
  final void Function(String)? onChanged;

  const InputToLoginSignUp({
    super.key,
    required this.controller,
    required this.icon,
    required this.labelText,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: icon,
        labelText: labelText,
        errorText: errorText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onChanged: onChanged,
    );
  }
}
