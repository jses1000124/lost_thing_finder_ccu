import 'package:flutter/material.dart';

class DevelopingScreen extends StatelessWidget {
  const DevelopingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('正在開發中><\n期待在正式版本與大家見面!',
          style: TextStyle(fontSize: 30), textAlign: TextAlign.center),
    );
  }
}
