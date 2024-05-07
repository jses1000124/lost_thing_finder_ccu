import 'package:flutter/material.dart';
import '../screens/setting_screen.dart';
import '../screens/login_screen.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              DrawerHeader(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      Theme.of(context).colorScheme.secondary.withOpacity(0.7),
                      Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                    ],
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.account_circle, size: 50),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text('使用者名稱',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              overflow: TextOverflow.ellipsis)),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('設定'),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const SettingsScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('登出'),
                onTap: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const LoginScreen()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
