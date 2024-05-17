import 'package:flutter/material.dart';
import 'package:final_project/screens/login_screen.dart';
import 'package:final_project/screens/regist_screen.dart';

void showAlertDialog(String title, String message, BuildContext context,
    {bool isRegister = false,
    bool popTwice = false,
    bool toScreen = false,
    bool success = false,
    bool toLogin = false}) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        icon: isRegister || success
            ? const Icon(Icons.check, color: Colors.green, size: 60)
            : const Icon(Icons.error,
                color: Color.fromARGB(255, 255, 97, 149), size: 60),
        title: Text(title,
            style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
        content: Text(message,
            style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
        actions: [
          TextButton(
            child: const Text(
              'OK',
            ),
            onPressed: () {
              if (isRegister) {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                    (route) => false);
              } else if (toLogin) {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                    (route) => false);
              } else if (popTwice) {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              } else if (toScreen) {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const RegisterScreen()),
                    (route) => false);
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      );
    },
  );
}
