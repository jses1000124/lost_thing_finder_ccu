import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:email_validator/email_validator.dart';
import '../widgets/user_input_login_signup.dart';
import '../screens/new_password_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var canSeePassword = true;
  bool _emailVerified = false;
  String? _emailError;

  void _validateEmail(String value) {
    setState(() {
      if (value.isEmpty) {
        _emailError = '請輸入信箱';
      } else if (!EmailValidator.validate(value)) {
        _emailError = '信箱格式錯誤';
      } else {
        _emailError = null;
      }
    });
  }

  void _sendVerificationEmail() {
    if (_emailController.text.isEmpty ||
        !EmailValidator.validate(_emailController.text)) {
      _showAlertDialog('錯誤', '尚未輸入信箱或格式不正確');
      return;
    } else {
      _showLoadingDialog(); // 顯示加載對話框
      verifyEmail().catchError((error) {
        Navigator.of(context).pop(); // 有錯誤也需要關閉加載對話框
        _showAlertDialog('錯誤', '出現錯誤: $error');
      });
    }
  }

  void _verifyCodeAndSetEmailVerified() async {
    final Uri apiUrl = Uri.parse('http://140.123.101.199:5000/verification');
    String code = codeController.text;
    String email = _emailController.text;
    try {
      await http
          .post(
            apiUrl,
            body: jsonEncode({
              'code': codeController.text,
              'email': _emailController.text,
            }),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5))
          .then(
            (response) {
              if (response.statusCode == 200) {
                setState(() {
                  _emailVerified = true; // Move setState outside the dialog
                });
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => NewPassword(
                      code: code,
                      email: email,
                    ),
                  ),
                );
              } else {
                _showAlertDialog('錯誤', '驗證碼錯誤');
                codeController.clear();
              }
            },
          );
      // 設定超時時間
    } on TimeoutException catch (_) {
      _showAlertDialog('超時', '驗證碼請求超時');
    } catch (e) {
      _showAlertDialog('錯誤', '未知錯誤：$e');
    }
  }

  void _showVerificationCodeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Makes dialog modal
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('輸入驗證碼'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: codeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: '6位數驗證碼',
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: _verifyCodeAndSetEmailVerified,
                  child: const Text('確認'),
                ),
              ],
            );
          },
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

  Future<void> verifyEmail() async {
    final Uri apiUrl =
        Uri.parse('http://140.123.101.199:5000/send_verification_code');
    Map<String, String> requestBody = {
      'email': _emailController.text,
    };
    try {
      await http
          .post(apiUrl,
              body: jsonEncode(requestBody),
              headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 5)) // 設定超時時間
          .then((response) {
            Navigator.of(context).pop(); // 關閉加載對話框
            if (response.statusCode == 200) {
              _showVerificationCodeDialog();
            } else {
              _showAlertDialog('錯誤', '請稍後再試');
            }
          });
    } on TimeoutException catch (_) {
      _showAlertDialog('超時', '驗證郵件請求超時');
    } catch (e) {
      _showAlertDialog('錯誤', '未知錯誤：$e');
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
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center),
          content: Text(message,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center),
          actions: [
            TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  if (popTwice) {
                    Navigator.of(context).pop();
                  }
                }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('驗證信箱'),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.arrow_back),
        //     onPressed: () {
        //       Navigator.of(context).pushReplacement(
        //         MaterialPageRoute(
        //           builder: (context) => const LoginScreen(),
        //         ),
        //       );
        //     },
        //   ),
        // ],
      ),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InputToLoginSignUp(
                    controller: _emailController,
                    icon: const Icon(Icons.mail),
                    labelText: '信箱',
                    errorText: _emailError,
                    onChanged: _validateEmail),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _emailVerified
                      ? null
                      : () {
                          if (!_emailVerified) {
                            _sendVerificationEmail();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _emailVerified
                        ? Colors.green
                        : null, // Use green color when verified
                  ),
                  child: Text(
                    _emailVerified ? '成功' : '驗證',
                    style: TextStyle(
                      color: _emailVerified ? Colors.black : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
