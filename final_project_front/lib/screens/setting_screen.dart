import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import '../models/theme_provider.dart';
import 'package:http/http.dart' as http;
import 'login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import '../models/user_nicknames.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int avatarIndex = 0;
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _checkNewPasswordController =
      TextEditingController();
  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  String? nickname;
  String? email;
  String? token;

  Future<void> _loadPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString('email') ?? '';
    nickname = prefs.getString('nickname') ?? '';
    token = prefs.getString('token') ?? '';
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
    return Consumer<UserPreferences>(builder: (context, userPrefs, child) {
      return Column(
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.account_circle, size: 40),
              title: Text(userPrefs.nickname,
                  style: const TextStyle(
                      fontSize: 20, overflow: TextOverflow.ellipsis)),
            ),
          ),
          Expanded(
            child: SettingsList(
              sections: [
                SettingsSection(
                  tiles: [
                    SettingsTile(
                      title: const Text('更改暱稱'),
                      leading: const Icon(Icons.person),
                      onPressed: (BuildContext context) =>
                          _changeNickName(context),
                    ),
                    SettingsTile(
                      title: const Text('更改頭像'),
                      leading: const Icon(Icons.image),
                      onPressed: (BuildContext context) =>
                          _changeAvatar(context),
                    ),
                  ],
                ),
                SettingsSection(
                  title: const Text('偏好設定'),
                  tiles: [
                    SettingsTile.switchTile(
                      title: const Text('切換深色模式'),
                      leading: const Icon(Icons.dark_mode),
                      initialValue: themeProvider.themeMode == ThemeMode.dark,
                      onToggle: (bool value) {
                        setState(() {
                          themeProvider.setThemeMode(
                              value ? ThemeMode.dark : ThemeMode.light);
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
                      onPressed: _changePassword,
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
          ),
        ],
      );
    });
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

  void _changePassword(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('更改密碼'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: '請輸入舊密碼',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  controller: _oldPasswordController,
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    hintText: '請輸入新密碼',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  controller: _newPasswordController,
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    hintText: '確認輸入新密碼',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  controller: _checkNewPasswordController,
                ),
                ElevatedButton(
                  onPressed: () {
                    _sendChangedPassword();
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
      {bool success = false, bool popTwice = false, bool toLogin = false}) {
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
                if (toLogin) {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const LoginScreen()));
                } else {
                  Navigator.of(context).pop();
                  if (popTwice) {
                    Navigator.of(context).pop();
                  }
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
      await http
          .post(
            apiUrl,
            body: jsonEncode(requestBody),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5))
          .then((response) {
            if (response.statusCode == 200) {
              setState(() {
                nickname = newNickName;
              });
              Provider.of<UserPreferences>(context, listen: false)
                  .updateNickname(newNickName);
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
          });
    } on TimeoutException catch (_) {
      _showAlertDialog('超時', '請求超時');
    } catch (e) {
      _showAlertDialog('錯誤', '發生未預期的錯誤：$e');
    }
  }

  Future<void> _sendChangedPassword() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String oldPassword = prefs.getString('password') ?? '';
    if (oldPassword != _oldPasswordController.text) {
      _showAlertDialog('錯誤', '舊密碼錯誤');
      return;
    }
    if (_oldPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _checkNewPasswordController.text.isEmpty) {
      _showAlertDialog('錯誤', '密碼不可為空');
      return;
    }
    if (_newPasswordController.text != _checkNewPasswordController.text) {
      _showAlertDialog('錯誤', '新密碼不一致');
      return;
    }

    final String inputOldPassword = _oldPasswordController.text;
    final String newPassword = _newPasswordController.text;
    final Uri apiUrl = Uri.parse('http://140.123.101.199:5000/change_password');
    final Map<String, String> requestBody = {
      'token': token!,
      'identifier': email!,
      'old_password': inputOldPassword,
      'new_password': newPassword,
    };
    try {
      await http
          .post(
            apiUrl,
            body: jsonEncode(requestBody),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5))
          .then((response) {
            if (response.statusCode == 200) {
              prefs.setString('password', newPassword);
              prefs.setBool('autoLogin', false);
              _showAlertDialog('成功', '密碼已更改', success: true, toLogin: true);
            } else {
              // 根據不同的錯誤代碼顯示不同的錯誤信息
              if (response.statusCode == 401) {
                _showAlertDialog('失敗', '無效的密碼');
              } else if (response.statusCode == 404) {
                _showAlertDialog('失敗', '帳號未找到');
              } else {
                _showAlertDialog('錯誤', '發生未預期的錯誤');
              }
            }
          });
    } on TimeoutException catch (_) {
      _showAlertDialog('超時', '請求超時');
    } catch (e) {
      _showAlertDialog('錯誤', '發生未預期的錯誤：$e');
    }
  }
}
