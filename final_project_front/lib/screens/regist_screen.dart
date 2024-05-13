import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_screen.dart';
import 'package:final_project/widgets/user_input_login_signup.dart';
import 'package:email_validator/email_validator.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var canSeePassword = true;
  bool _emailVerified = false;

  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  void _validateUsername(String value) {
    setState(() {
      if (value.isEmpty) {
        _usernameError = '請輸入帳號';
      } else {
        _usernameError = null;
      }
    });
  }

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
        _confirmPasswordError = '請輸入確認密碼';
      } else if (value != _passwordController.text) {
        _confirmPasswordError = '密碼並不一致';
      } else {
        _confirmPasswordError = null;
      }
    });
  }

  void _sendVerificationEmail() {
    if (_accountController.text.isEmpty ||
        !EmailValidator.validate(_accountController.text)) {
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
    try {
      await http
          .post(
            apiUrl,
            body: jsonEncode({
              'code': codeController.text,
              'email': _accountController.text,
            }),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 7))
          .then(
            (response) {
              if (response.statusCode == 200) {
                setState(() {
                  _emailVerified = true; // Move setState outside the dialog
                });
                Navigator.of(context).pop(); // Close the dialog
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
      'email': _accountController.text,
    };
    try {
      await http
          .post(apiUrl,
              body: jsonEncode(requestBody),
              headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 5)) // 設定超時時間
          .then((response) {
            if (response.statusCode == 200) {
              _showVerificationCodeDialog();
            } else {
              _showAlertDialog('錯誤', '請稍後再試', popTwice: true);
            }
          });
    } on TimeoutException catch (_) {
      _showAlertDialog('超時', '驗證郵件請求超時', popTwice: true);
    } catch (e) {
      _showAlertDialog('錯誤', '未知錯誤：$e', popTwice: true);
    }
  }

  Future<void> _signUp() async {
    if (!_emailVerified) {
      _showAlertDialog('錯誤', '請先驗證您的信箱');
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String username = _usernameController.text;
    final String account = _accountController.text;
    final String password = _passwordController.text;
    final String code = codeController.text;

    final Uri apiUrl = Uri.parse('http://140.123.101.199:5000/register');
    final Map<String, String> requestBody = {
      'account': account,
      'password': password,
      'username': username,
      'code': code,
    };

    try {
      await http
          .post(apiUrl,
              body: jsonEncode(requestBody),
              headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 5)) // 設定超時時間
          .then((response) {
            if (response.statusCode == 201) {
              _showAlertDialog('成功', '帳號已成功建立', isRegister: true);
            } else if (response.statusCode == 400) {
              _clearTextFields();
              _showAlertDialog('失敗', '帳號已存在', popTwice: true);
            } else {
              _showAlertDialog('錯誤', '請稍後再試', popTwice: true);
            }
          });
    } on TimeoutException catch (_) {
      _showAlertDialog('超時', '註冊請求超時', popTwice: true);
    } catch (e) {
      _showAlertDialog('錯誤', '未知錯誤：$e', popTwice: true);
    }
  }

  void _clearTextFields() {
    _usernameController.clear();
    _accountController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    codeController.clear();
  }

  void _showAlertDialog(String title, String message,
      {bool isRegister = false, bool popTwice = false, bool toScreen = false}) {
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
              child: const Text(
                'OK',
              ),
              onPressed: () {
                if (isRegister) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const LoginScreen()));
                } else if (popTwice) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                } else if (toScreen) {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const RegisterScreen()));
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _accountController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    controller: _usernameController,
                    icon: const Icon(Icons.person),
                    labelText: '帳號',
                    errorText: _usernameError,
                    onChanged: _validateUsername),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      flex: 14,
                      child: InputToLoginSignUp(
                          controller: _accountController,
                          icon: const Icon(Icons.mail),
                          labelText: '信箱',
                          errorText: _emailError,
                          onChanged: _validateEmail),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 4,
                      child: TextButton(
                        onPressed: _emailVerified
                            ? null
                            : () {
                                if (!_emailVerified) {
                                  _sendVerificationEmail();
                                }
                              },
                        style: TextButton.styleFrom(
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
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
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
                const SizedBox(height: 20),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline),
                    labelText: '確認密碼',
                    errorText: _confirmPasswordError,
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
                  onChanged: _validateConfirmPassword,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(150, 50),
                  ),
                  onPressed: _signUp,
                  child: const Text('註冊', style: TextStyle(fontSize: 25)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('已有帳號?', style: TextStyle(fontSize: 18)),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => const LoginScreen()));
                      },
                      child: const Text('登入', style: TextStyle(fontSize: 18)),
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
