import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_screen.dart';

class NewPassword extends StatefulWidget {
  const NewPassword({super.key, required this.email, required this.code});
  final String email;
  final String code;

  @override
  State<NewPassword> createState() => _NewPasswordState();
}

class _NewPasswordState extends State<NewPassword> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var canSeePassword = true;

  String? _passwordError;
  String? _confirmPasswordError;

  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _passwordError = '請輸入密碼';
      } else {
        _passwordError = null;
      }
    });
  }

  void _validateConfirmPassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _confirmPasswordError = '請再次輸入密碼';
      } else if (value != _passwordController.text) {
        _confirmPasswordError = '密碼不一致';
      } else {
        _confirmPasswordError = null;
      }
    });
  }

  Future<void> _newPassword() async {
    if (_passwordError != null || _confirmPasswordError != null) {
      _showAlertDialog('失敗', '請填寫密碼');
      return;
    }

    final String password = _passwordController.text;

    final Uri apiUrl =
        Uri.parse('http://140.123.101.199:5000/change_password_with_email');
    final Map<String, String> requestBody = {
      'new_password': password,
      'identifier': widget.email,
      'code': widget.code,
    };
    try {
      final response = await http.post(
        apiUrl,
        body: jsonEncode(requestBody),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5)); // 設定5秒超時

      if (response.statusCode == 200) {
        _showAlertDialog('成功', '密碼設定成功', isRegister: true);
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

  void _showAlertDialog(String title, String message,
      {bool isRegister = false, bool popTwice = false}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: isRegister
              ? const Icon(Icons.check, color: Colors.green, size: 60)
              : const Icon(Icons.error,
                  color: Color.fromARGB(255, 255, 97, 149), size: 60),
          title: Text(title,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center),
          content: Text(message,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center),
          actions: [
            TextButton(
              child: const Text('OK', style: TextStyle(color: Colors.white)),
              onPressed: () {
                if (isRegister) {
                  Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定新密碼'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock),
                      labelText: '密碼',
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
                    validator: (value) {
                      _validatePassword(value!);
                      return _passwordError;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline),
                      labelText: '確認密碼',
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
                    validator: (value) {
                      _validateConfirmPassword(value!);
                      return _confirmPasswordError;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _newPassword,
                    child: const Text(
                      '確認',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
