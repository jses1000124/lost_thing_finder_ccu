import 'package:flutter/material.dart';
import '../screens/setting_screen.dart';
import '../screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  Future<String> _getAccount() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('nickname') ?? '未設定';
  }

  @override
  Widget build(BuildContext context) {
    Future<void> logout() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('autoLogin', false);
      await prefs.setString('account', '');
      await prefs.setString('password', '').then((value) =>
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginScreen())));
    }

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
                child: FutureBuilder<String>(
                  future: _getAccount(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Icon(Icons.account_circle, size: 50),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(snapshot.data!,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    overflow: TextOverflow.ellipsis)),
                          ),
                        ],
                      );
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('設定'),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const SettingsPage()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('登出'),
                onTap: logout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
