import 'dart:convert';
import 'dart:async';
import 'package:final_project/data/getuserdata.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'bottom_bar.dart';
import 'package:final_project/widgets/user_input_login_signup.dart';
import 'regist_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'verify_email_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var canSeePassword = true;
  bool _autoLogin = false;

  String? _emailOrAccountError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _checkPreferences();
  }

  Future<void> _checkPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('autoLogin') ?? false) {
      _accountController.text = prefs.getString('account') ?? '';
      _passwordController.text = prefs.getString('password') ?? '';
      _autoLogin = true;
      _login();
    }
  }

  void _validateEmail(String value) {
    setState(() {
      if (value.isEmpty) {
        _emailOrAccountError = '請輸入信箱或帳號';
      } else {
        _emailOrAccountError = null;
      }
    });
  }

  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _passwordError = '請輸入密碼';
      } else {
        _passwordError = null;
      }
    });
  }

  Future<void> _login() async {
    if (_emailOrAccountError != null || _passwordError != null) {
      _showAlertDialog('失敗', '請填寫帳號密碼');
      return;
    }

    final String account = _accountController.text;
    final String password = _passwordController.text;

    final Uri apiUrl = Uri.parse('http://140.123.101.199:5000/login');
    final Map<String, String> requestBody = {
      'account': account,
      'password': password,
    };

    try {
      final response = await http.post(
        apiUrl,
        body: jsonEncode(requestBody),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5)); // 設定5秒超時

      if (response.statusCode == 200) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('account', account);
        await prefs.setString('password', password);
        await prefs.setString('token', jsonDecode(response.body)['token']);
        await GetUserData().getUserData();
        await prefs.setBool('autoLogin', _autoLogin).then((value) =>
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const BottomBar())));
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
    } on TimeoutException catch (_) {
      _showAlertDialog('超時', '請求超時');
    } catch (e) {
      _showAlertDialog('錯誤', '發生未預期的錯誤：$e');
    }
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(Icons.error,
              color: Color.fromARGB(255, 255, 97, 149), size: 60),
          title: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          content: Text(message,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center),
          actions: <Widget>[
            TextButton(
              child: const Text('OK', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
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
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),
                InputToLoginSignUp(
                  controller: _accountController,
                  icon: const Icon(Icons.person),
                  labelText: '帳號或信箱',
                  errorText: _emailOrAccountError,
                  onChanged: _validateEmail,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  style: const TextStyle(color: Colors.white),
                  controller: _passwordController,
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
                      const Text('自動登入',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
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
                      // onPressed: () => Navigator.of(context).pushReplacement(
                      //     MaterialPageRoute(
                      //         builder: (context) =>
                      //             const BottomBar())),
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
                      style: TextStyle(color: Colors.white, fontSize: 18),
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
