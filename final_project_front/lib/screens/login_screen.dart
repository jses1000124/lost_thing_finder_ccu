import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'bottom_bar.dart';
import 'package:final_project/widgets/user_input_login_signup.dart';
import 'regist_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String account = _accountController.text;
    final String password = _passwordController.text;

    final Uri apiUrl = Uri.parse('http://140.123.101.199:5000/login');
    final Map<String, String> requestBody = {
      'account': account,
      'password': password,
    };
    final response = await http.post(apiUrl,
        body: jsonEncode(requestBody),
        headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('account', account);
      await prefs.setBool('isLoggedIn', true);
      await prefs.setBool('autoLogin', _autoLogin).then((value) =>
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const BottomBar())));
    } else {
      if (response.statusCode == 401) {
        _showAlertDialog('Failed', 'Invalid password');
      } else if (response.statusCode == 404) {
        _showAlertDialog('Failed', 'Account not found');
      } else {
        _showAlertDialog('Error', 'An unexpected error occurred');
      }
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
