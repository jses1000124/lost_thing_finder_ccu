import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_nicknames.dart'; 
import '../screens/setting_screen.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserPreferences>(
      builder: (context, userPrefs, child) {
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
                          Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.7),
                          Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.3),
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Icon(Icons.account_circle, size: 50),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            userPrefs
                                .nickname,
                            style: const TextStyle(
                                fontSize: 20, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ],
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
