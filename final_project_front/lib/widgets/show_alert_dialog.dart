import 'package:flutter/material.dart';

class ShowAlertDialog{
  void showAlertDialog(String title, String message,BuildContext context,{bool popTwice = false}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(Icons.error,
              color: Color.fromARGB(255, 255, 97, 149), size: 60),
          title: Text(
            title,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          content: Text(message,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                if (popTwice) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}