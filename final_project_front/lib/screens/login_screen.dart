import 'dart:convert';
import 'dart:async';
import 'package:final_project/data/get_user_data.dart';
import 'package:final_project/models/lost_thing_and_Url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'main_page.dart';
import 'package:final_project/widgets/user_input_login_signup.dart';
import 'regist_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'verify_email_screen.dart';
import 'package:final_project/widgets/show_alert_dialog.dart';
import '../widgets/show_loading_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FocusNode _accountFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  var canSeePassword = true;
  bool _autoLogin = false;

  String? _emailOrAccountError;
  String? _passwordError;

  void _validateAccountEmail(String value) {
    setState(() {
      if (value.isEmpty) {
        _emailOrAccountError = '請輸入信箱或帳號';
      } else if (!RegExp(r'^[A-Za-z0-9!@#\$&*~]+$').hasMatch(value)) {
        _emailOrAccountError = '信箱或帳號只能包含英文、數字和符號';
      } else {
        _emailOrAccountError = null;
      }
    });
  }

  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _passwordError = '請輸入密碼';
      } else if (!RegExp(r'^[A-Za-z0-9!@#\$&*~]+$').hasMatch(value)) {
        _passwordError = '密碼只能包含英文、數字和符號';
      } else {
        _passwordError = null;
      }
    });
  }

  Future<void> _login() async {
    if (_accountController.text.isEmpty || _passwordController.text.isEmpty) {
      showAlertDialog('失敗', '請填寫帳號密碼', context);
      return;
    }
    showLoadingDialog(context);
    final String account = _accountController.text;
    final String password = _passwordController.text;

    final Uri apiUrl = Uri.parse('$basedApiUrl/login');
    final Map<String, String> requestBody = {
      'account': account,
      'password': password,
    };

    try {
      await http
          .post(
            apiUrl,
            body: jsonEncode(requestBody),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 8))
          .then((response) async {
            if (response.statusCode == 200) {
              Navigator.of(context).pop();
              final SharedPreferences prefs =
                  await SharedPreferences.getInstance();
              await prefs.setString('account', account);
              await prefs.setString('password', password);
              await prefs.setString(
                  'token', jsonDecode(response.body)['token']);
              if (!mounted) return;
              await GetUserData().getUserData(context);
              await prefs.setBool('autoLogin', _autoLogin).then((value) =>
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const MainPage())));
            } else {
              // 根據不同的錯誤代碼顯示不同的錯誤信息
              if (response.statusCode == 401) {
                Navigator.of(context).pop();
                showAlertDialog('失敗', '無效的密碼', context);
              } else if (response.statusCode == 404) {
                Navigator.of(context).pop();
                showAlertDialog('失敗', '帳號未找到', context);
              } else if (response.statusCode == 987) {
                Navigator.of(context).pop();
                showAlertDialog('失敗', '輸入錯誤密碼超過三次\n為了保護您的帳號，已封鎖15分鐘', context);
              } else {
                Navigator.of(context).pop();
                showAlertDialog('錯誤', '發生未預期的錯誤', context);
              }
            }
          }); // 設定8秒超時
    } on TimeoutException catch (_) {
      if (!mounted) return; // Ensure the widget is still mounted
      Navigator.of(context).pop();
      showAlertDialog('超時', '請求超時', context);
    } catch (e) {
      if (!mounted) return; // Ensure the widget is still mounted
      Navigator.of(context).pop();
      showAlertDialog('錯誤', '發生未預期的錯誤：$e', context);
    }
  }

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    _accountFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '中正大學\n失物招領系統',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),
                FocusScope(
                  node: FocusScopeNode(),
                  child: Column(
                    children: [
                      InputToLoginSignUp(
                        controller: _accountController,
                        focusNode: _accountFocusNode,
                        icon: const Icon(Icons.person),
                        labelText: '帳號或信箱',
                        errorText: _emailOrAccountError,
                        onChanged: _validateAccountEmail,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),
                          labelText: '密碼',
                          errorText: _passwordError,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(canSeePassword
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                canSeePassword = !canSeePassword;
                              });
                            },
                          ),
                        ),
                        obscureText: canSeePassword,
                        onChanged: _validatePassword,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _autoLogin,
                        onChanged: (bool? value) {
                          setState(() {
                            _autoLogin = value!;
                          });
                        },
                      ),
                      const Text('自動登入', style: TextStyle(fontSize: 16)),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const VerifyEmailScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          '忘記密碼?',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(150, 50),
                      ),
                      onPressed: _login,
                      child: const Text('登入', style: TextStyle(fontSize: 25)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '還沒有帳號?',
                      style: TextStyle(fontSize: 18),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        '立即註冊',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
