import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import '../models/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String nickname = "User";
  int avatarIndex = 0;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text('更改用戶資料'),
            tiles: [
              SettingsTile(
                title: const Text('更改暱稱'),
                leading: const Icon(Icons.person),
                onPressed: (BuildContext context) {},
              ),
              SettingsTile(
                title: const Text('更改密碼'),
                leading: const Icon(Icons.lock),
                onPressed: (BuildContext context) {},
              ),
              SettingsTile(
                title: const Text('更改頭像'),
                leading: const Icon(Icons.image),
                onPressed: (BuildContext context) => _changeAvatar(context),
              ),
            ],
          ),
          SettingsSection(
            title: const Text('偏好設定'),
            tiles: [
              SettingsTile.switchTile(
                title: const Text('切換暗黑模式'),
                leading: const Icon(Icons.dark_mode),
                initialValue: themeProvider.themeMode == ThemeMode.dark,
                onToggle: (bool value) {
                  setState(() {
                    themeProvider
                        .setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                  });
                },
              ),
            ],
          ),
          SettingsSection(
            title: const Text('回饋'),
            tiles: [
              SettingsTile(
                title: const Text('與我們聯絡'),
                leading: const Icon(Icons.mail),
                onPressed: (BuildContext context) {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _changeAvatar(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('選擇頭像'),
          content: SingleChildScrollView(
            child: ListBody(
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      avatarIndex = index;
                      Navigator.of(context).pop();
                    });
                  },
                  child: Image.asset('assets/avatar_$index.png'),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
