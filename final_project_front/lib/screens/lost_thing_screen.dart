import 'package:flutter/material.dart';
import '../drawer/main_drawer.dart';

class LostThingScreen extends StatelessWidget {
  const LostThingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.4,
        title: const Text('Lost Thing'),
      ),
      drawer: const MainDrawer(),
      body: const Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search, size: 100),
              SizedBox(height: 20),
              Text('No Lost Thing Yet',
                  style: TextStyle(fontSize: 30, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
