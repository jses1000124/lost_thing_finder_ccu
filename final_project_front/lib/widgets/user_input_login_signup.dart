import 'package:flutter/material.dart';

class InputToLoginSignUp extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Icon icon;
  final String labelText;
  final String? errorText;
  final void Function(String)? onChanged;
  final bool readOnly;

  const InputToLoginSignUp({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.icon,
    required this.labelText,
    this.errorText,
    this.onChanged,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      readOnly: readOnly,
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