import 'package:final_project/models/lost_thing_and_Url.dart';
import 'package:final_project/models/userimg_id_provider.dart';
import 'package:final_project/screens/my_posts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../models/theme_provider.dart';
import 'package:http/http.dart' as http;
import 'login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import '../models/user_nicknames.dart';
import '../data/get_nickname.dart';
import 'change_passwd_in_login_page.dart';
import 'package:mailto/mailto.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/show_alert_dialog.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
    token = prefs.getString('token') ?? '';
    nickname = await getNickname(email!);
    setState(() {});
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
    final userImgIdProvider =
        Provider.of<UserImgIdProvider>(context, listen: false);
    return Consumer<UserPreferences>(builder: (context, userPrefs, child) {
      return SettingsList(
        sections: [
          SettingsSection(
            tiles: [
              SettingsTile(
                title: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .secondaryContainer
                        .withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage(
                          'assets/images/avatar_${userImgIdProvider.userImgId}.png'),
                    ),
                    title: Text(userPrefs.nickname,
                        style: const TextStyle(
                            fontSize: 20,
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
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
              SettingsTile(
                  title: const Text('我的貼文'),
                  leading: const Icon(FontAwesomeIcons.pen),
                  onPressed: (BuildContext context) =>
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const MyPostsScreen(),
                      ))),
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
                onPressed: (BuildContext context) async {
                  final mailtoLink = Mailto(
                    to: ['ccufinalproject@gmail.com'],
                    subject: '',
                    body: '',
                  );
                  await launchUrlString('$mailtoLink');
                },
              ),
            ],
          ),
          SettingsSection(
            title: const Text('帳號安全˙'),
            tiles: [
              SettingsTile(
                  title: const Text('更改密碼'),
                  leading: const Icon(Icons.lock),
                  onPressed: (BuildContext context) =>
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const ChangePasswordScreen(),
                      ))),
              SettingsTile(
                title: const Text('登出'),
                leading: const Icon(Icons.logout),
                onPressed: (BuildContext context) => logout(),
              ),
            ],
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
          content: SizedBox(
            width: double.maxFinite,
            height: 300, // Set a fixed height to control the dialog size
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children:
                      List.generate(3, (index) => _buildAvatar(context, index)),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                      2, (index) => _buildAvatar(context, index + 3)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 用戶不能通過點擊外部來關閉對話框
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20), // 提供一些水平空間
                Text("正在處理...", style: TextStyle(fontSize: 16)), // 顯示加載信息
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _sendChangedUserImgId(int index) async {
    final Uri apiUrl = Uri.parse('$basedApiUrl/update_headshot');
    final Map<String, String> requestBody = {
      'token': token!,
      'userimg': index.toString(),
    };
    final userImgIdProvider =
        Provider.of<UserImgIdProvider>(context, listen: false);
    _showLoadingDialog();
    try {
      await http
          .post(
            apiUrl,
            body: jsonEncode(requestBody),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5))
          .then((response) async {
            if (response.statusCode == 200) {
              Navigator.of(context).pop(); // 關閉加載對話框
              await userImgIdProvider.updateUserImgId(index.toString());
              setState(() {});
              showAlertDialog('成功', '頭像已更改\n(有時需要重新啟動App)',context,
                  success: true, popTwice: true);
            } else {
              // 根據不同的錯誤代碼顯示不同的錯誤信息
              if (response.statusCode == 401) {
                Navigator.of(context).pop(); // 關閉加載對話框
                showAlertDialog('失敗', '無效的頭像',context);
              } else if (response.statusCode == 404) {
                Navigator.of(context).pop(); // 關閉加載對話框
                showAlertDialog('失敗', '帳號未找到',context);
              } else {
                Navigator.of(context).pop(); // 關閉加載對話框
                showAlertDialog('錯誤', '發生未預期的錯誤',context);
              }
            }
          });
    } on TimeoutException catch (_) {
      Navigator.of(context).pop(); // 關閉加載對話框
      showAlertDialog('超時', '請求超時',context);
    } catch (e) {
      Navigator.of(context).pop(); // 關閉加載對話框
      showAlertDialog('錯誤', '發生未預期的錯誤：$e',context);
    }
  }

  Widget _buildAvatar(BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
        _sendChangedUserImgId(index);
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        height: 80,
        width: 80,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: AssetImage('assets/images/avatar_$index.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
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
                  maxLength: 10,
                  decoration: const InputDecoration(
                    hintText: '請輸入新暱稱',
                  ),
                  controller: _nicknameController,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('取消'),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        _sendChangedNickName();
                      },
                      child: const Text('確認'),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }



  Future<void> _sendChangedNickName() async {
    if (_nicknameController.text.isEmpty) {
      showAlertDialog('錯誤', '暱稱不可為空',context);
      return;
    }
    final String newNickName = _nicknameController.text;
    final Uri apiUrl = Uri.parse('$basedApiUrl/update_nickname');
    final Map<String, String> requestBody = {
      'token': token!,
      'identifier': email!,
      'new_nickname': newNickName,
    };
    _showLoadingDialog();
    try {
      await http
          .post(
            apiUrl,
            body: jsonEncode(requestBody),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5))
          .then((response) async {
            if (response.statusCode == 200) {
              await Provider.of<UserPreferences>(context, listen: false)
                  .updateNickname(newNickName);
              setState(() {
                nickname = newNickName;
              });
              Navigator.of(context).pop(); // 關閉加載對話框

              showAlertDialog('成功', '暱稱已更改',context, success: true, popTwice: true);
            } else {
              // 根據不同的錯誤代碼顯示不同的錯誤信息
              if (response.statusCode == 401) {
                Navigator.of(context).pop(); // 關閉加載對話框
                showAlertDialog('失敗', '無效的暱稱',context);
              } else if (response.statusCode == 404) {
                Navigator.of(context).pop(); // 關閉加載對話框
                showAlertDialog('失敗', '帳號未找到',context);
              } else {
                Navigator.of(context).pop(); // 關閉加載對話框
                showAlertDialog('錯誤', '發生未預期的錯誤',context);
              }
            }
          });
    } on TimeoutException catch (_) {
      Navigator.of(context).pop(); // 關閉加載對話框
      showAlertDialog('超時', '請求超時',context);
    } catch (e) {
      Navigator.of(context).pop(); // 關閉加載對話框
      showAlertDialog('錯誤', '發生未預期的錯誤：$e',context);
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _checkNewPasswordController.dispose();
    super.dispose();
  }
}
