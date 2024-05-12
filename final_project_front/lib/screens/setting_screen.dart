import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import '../models/theme_provider.dart';
import 'package:http/http.dart' as http;
import 'login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int avatarIndex = 0;
  final TextEditingController _nicknameController = TextEditingController();
  @override
  void initState() {
    _checkPreferences();
    super.initState();
  }

  String? nickname;
  String? email;
  String? token;
  String? oldPassword;

  Future<void> _checkPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email') ?? '';
      nickname = prefs.getString('nickname') ?? '';
      token = prefs.getString('token') ?? '';
      oldPassword = prefs.getString('password') ?? '';
    });
  }

  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoLogin', false);
    await prefs.setString('account', '');
    await prefs.setString('password', '').then((value) => Navigator.of(context)
        .pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen())));
  }

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
            title: Card(
              child: ListTile(
                leading: const Icon(Icons.account_circle, size: 40),
                title: Text(nickname!,
                    style: const TextStyle(
                        fontSize: 20, overflow: TextOverflow.ellipsis)),
              ),
            ),
            tiles: [
              SettingsTile(
                title: const Text('更改暱稱'),
                leading: const Icon(Icons.person),
                onPressed: (BuildContext context) => _changeNickName(context),
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
          SettingsSection(
            title: const Text('帳號安全˙'),
            tiles: [
              SettingsTile(
                title: const Text('更改密碼'),
                leading: const Icon(Icons.lock),
                onPressed: (BuildContext context) {},
              ),
              SettingsTile(
                title: const Text('登出'),
                leading: const Icon(Icons.logout),
                onPressed: (BuildContext context) => logout(),
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

  void _changeNickName(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('更改暱稱'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: '請輸入新暱稱',
                  ),
                  controller: _nicknameController,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _sendChangedNickName();
                  },
                  child: const Text('確認'),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAlertDialog(String title, String message,
      {bool success = false, bool popTwice = false}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: success
              ? const Icon(Icons.check, color: Colors.green, size: 60)
              : const Icon(Icons.error,
                  color: Color.fromARGB(255, 255, 97, 149), size: 60),
          title: Text(title,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center),
          content: Text(message,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center),
          actions: [
            TextButton(
              child: const Text(
                'OK',
              ),
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

  Future<void> _sendChangedNickName() async {
    if (_nicknameController.text.isEmpty) {
      _showAlertDialog('錯誤', '暱稱不可為空');
      return;
    }
    final String newNickName = _nicknameController.text;
    final Uri apiUrl = Uri.parse('http://140.123.101.199:5000/update_nickname');
    final Map<String, String> requestBody = {
      'token': token!,
      'identifier': email!,
      'new_nickname': newNickName,
    };
    try {
      final response = await http.post(
        apiUrl,
        body: jsonEncode(requestBody),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5)); // 設定5秒超時

      if (response.statusCode == 200) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('nickname', newNickName);
        _checkPreferences();
        _showAlertDialog('成功', '暱稱已更改', success: true, popTwice: true);
      } else {
        // 根據不同的錯誤代碼顯示不同的錯誤信息
        if (response.statusCode == 401) {
          _showAlertDialog('失敗', '無效的暱稱');
        } else if (response.statusCode == 404) {
          _showAlertDialog('失敗', '帳號未找到');
        } else {
          _showAlertDialog('錯誤', '發生未預期的錯誤');
        }
      }
    } on TimeoutException catch (_) {
      _showAlertDialog('超時', '請求超時');
    } catch (e) {
      _showAlertDialog('錯誤', '發生未預期的錯誤：$e');
    }
  }
}
