import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool darkMode = false;
  String nickname = "User";
  int avatarIndex = 0; // 預設選擇第一個頭像

  @override
  Widget build(BuildContext context) {
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
                onPressed: (BuildContext context) {
                  // 加入更改暱稱的邏輯
                },
              ),
              SettingsTile(
                title: const Text('更改密碼'),
                leading: const Icon(Icons.lock),
                onPressed: (BuildContext context) {
                  // 加入更改密碼的邏輯
                },
              ),
              SettingsTile(
                title: const Text('更改頭像'),
                leading: const Icon(Icons.image),
                onPressed: (BuildContext context) {
                  // 弹出选择头像对话框
                  _changeAvatar(context);
                },
              ),
            ],
          ),
          SettingsSection(
            title: const Text('偏好設定'),
            tiles: [
              SettingsTile.switchTile(
                title: const Text('切換暗黑模式'),
                leading: const Icon(Icons.dark_mode),
                initialValue: darkMode = true,
                onToggle: (bool value) {
                  setState(() {
                    darkMode = value;
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
                onPressed: (BuildContext context) {
                  // 加入聯絡方式的邏輯
                },
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
