import 'dart:convert';
import 'dart:async';
import 'package:final_project/models/lost_thing_and_Url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:email_validator/email_validator.dart';
import '../widgets/user_input_login_signup.dart';
import '../screens/new_password_screen.dart';
import '../widgets/show_alert_dialog.dart';
import '../widgets/show_loading_dialog.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _codeFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
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
      showAlertDialog('錯誤', '尚未輸入信箱或格式不正確', context);
      return;
    } else {
      showLoadingDialog(context); // 顯示加載對話框
      verifyEmail().catchError((error) {
        Navigator.of(context).pop(); // 有錯誤也需要關閉加載對話框
        showAlertDialog('錯誤', '出現錯誤: $error', context);
      });
    }
  }

  void _verifyCodeAndSetEmailVerified() async {
    final Uri apiUrl = Uri.parse('$basedApiUrl/verification');
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
                showAlertDialog('錯誤', '驗證碼錯誤', context);
                codeController.clear();
              }
            },
          );
    } on TimeoutException catch (_) {
      if (!mounted) return;
      showAlertDialog('超時', '驗證碼請求超時', context);
    } catch (e) {
      if (!mounted) return;
      showAlertDialog('錯誤', '未知錯誤：$e', context);
    }
  }

  void _showVerificationCodeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
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
                    focusNode: _codeFocusNode,
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

  Future<void> verifyEmail() async {
    final Uri apiUrl = Uri.parse('$basedApiUrl/send_verification_code');
    Map<String, String> requestBody = {
      'email': _emailController.text,
    };
    try {
      await http
          .post(apiUrl,
              body: jsonEncode(requestBody),
              headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10))
          .then((response) {
            Navigator.of(context).pop();
            if (response.statusCode == 200) {
              _showVerificationCodeDialog();
            } else {
              showAlertDialog('錯誤', '請稍後再試', context);
            }
          });
    } on TimeoutException catch (_) {
      if (!mounted) return; 
      Navigator.of(context).pop(); 
      showAlertDialog('超時', '驗證郵件請求超時', context);
    } catch (e) {
      if (!mounted) return; 
      Navigator.of(context).pop(); 
      showAlertDialog('錯誤', '未知錯誤：$e', context);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    codeController.dispose();
    _emailFocusNode.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('驗證信箱'),
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
                    focusNode: _emailFocusNode,
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
                        : null,
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
}
