import 'package:flutter/material.dart';

class InputToLoginSignUp extends StatelessWidget {
  const InputToLoginSignUp(
      {super.key,
      required this.controller,
      required this.icon,
      required this.labelText});
  final TextEditingController controller;
  final Icon icon;
  final String labelText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: const TextStyle(color: Colors.white),
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: icon,
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
