import 'dart:convert';
import 'dart:async';
import 'package:final_project/models/lost_thing_and_Url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_screen.dart';
import 'package:final_project/widgets/user_input_login_signup.dart';
import 'package:email_validator/email_validator.dart';
import '../widgets/show_alert_dialog.dart';
import '../widgets/show_loading_dialog.dart';

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
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _accountFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  var canSeePassword = true;
  bool _emailVerified = false;

  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _passwordComplexityError;

  void _validateUsername(String value) {
    setState(() {
      if (value.isEmpty) {
        _usernameError = '請輸入帳號';
      } else if (!RegExp(r'^[A-Za-z0-9!@#\$&*~]+$').hasMatch(value)) {
        _usernameError = '帳號只能包含英文和符號';
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
        _passwordComplexityError = null;
      } else if (!RegExp(r'^[A-Za-z0-9!@#\$&*~]+$').hasMatch(value)) {
        _passwordError = '密碼只能包含英文和符號';
        _passwordComplexityError = null;
      } else if (value.length < 8 ||
          !RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$').hasMatch(value)) {
        _passwordError = null;
        _passwordComplexityError = '密碼必須有8個字，且須由英文加數字組合';
      } else {
        _passwordError = null;
        _passwordComplexityError = null;
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
      showAlertDialog('錯誤', '尚未輸入信箱或格式不正確', context);
      return;
    } else if (!_formKey.currentState!.validate()) {
      return;
    } else {
      showLoadingDialog(context); 
      verifyEmail().catchError((error) {
        Navigator.of(context).pop(); 
        showAlertDialog('錯誤', '出現錯誤: $error', context);
      });
    }
  }

  void _verifyCodeAndSetEmailVerified() async {
    final Uri apiUrl = Uri.parse('$basedApiUrl/verification');
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
          .timeout(const Duration(seconds: 10))
          .then(
            (response) {
              if (response.statusCode == 200) {
                Navigator.of(context).pop(); 
                setState(() {
                  _emailVerified = true; 
                });
                Navigator.of(context).pop(); 
                _signUp();
              } else {
                showAlertDialog('錯誤', '驗證碼錯誤', context);
                codeController.clear();
              }
            },
          );
    } on TimeoutException catch (_) {
      if (!mounted) return; 
      showAlertDialog('超時', '驗證碼請求超時', context, popTwice: true);
    } catch (e) {
      if (!mounted) return;
      showAlertDialog('錯誤', '未知錯誤：$e', context, popTwice: true);
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
      'email': _accountController.text,
    };
    try {
      await http
          .post(apiUrl,
              body: jsonEncode(requestBody),
              headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 5))
          .then((response) {
            if (response.statusCode == 200) {
              _showVerificationCodeDialog();
            } else {
              showAlertDialog('錯誤', '請稍後再試', context, popTwice: true);
            }
          });
    } on TimeoutException catch (_) {
      if (!mounted) return;
      showAlertDialog('超時', '驗證郵件請求超時', context, popTwice: true);
    } catch (e) {
      if (!mounted) return;
      showAlertDialog('錯誤', '未知錯誤：$e', context, popTwice: true);
    }
  }

  Future<void> _signUp() async {
    if (!_emailVerified) {
      showAlertDialog('錯誤', '請先驗證您的信箱', context);
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String username = _usernameController.text;
    final String account = _accountController.text;
    final String password = _passwordController.text;
    final String code = codeController.text;

    final Uri apiUrl = Uri.parse('$basedApiUrl/register');
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
          .timeout(const Duration(seconds: 5))
          .then((response) {
            if (response.statusCode == 201) {
              showAlertDialog('成功', '帳號已成功建立', context, isRegister: true);
            } else if (response.statusCode == 400) {
              _clearTextFields();
              showAlertDialog('失敗', '使用者名稱或信箱已被註冊', context, popTwice: true);
            } else if (response.statusCode == 404) {
              showAlertDialog('失敗', '密碼不符合複雜度要求', context, popTwice: true);
            } else {
              showAlertDialog('錯誤', '請稍後再試', context, popTwice: true);
            }
          });
    } on TimeoutException catch (_) {
      if (!mounted) return; 
      showAlertDialog('超時', '註冊請求超時', context, popTwice: true);
    } catch (e) {
      if (!mounted) return; 
      showAlertDialog('錯誤', '未知錯誤：$e', context, popTwice: true);
    }
  }

  void _clearTextFields() {
    _usernameController.clear();
    _accountController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    codeController.clear();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _accountController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    codeController.dispose();
    _usernameFocusNode.dispose();
    _accountFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
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
                    focusNode: _usernameFocusNode,
                    icon: const Icon(Icons.person),
                    labelText: '帳號',
                    maxlength: 15,
                    errorText: _usernameError,
                    onChanged: _validateUsername),
                const SizedBox(height: 20),
                InputToLoginSignUp(
                    controller: _accountController,
                    focusNode: _accountFocusNode,
                    icon: const Icon(Icons.mail),
                    readOnly: _emailVerified,
                    labelText: '信箱',
                    errorText: _emailError,
                    onChanged: _validateEmail),
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
                const SizedBox(height: 20),
                TextFormField(
                  controller: _confirmPasswordController,
                  focusNode: _confirmPasswordFocusNode,
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
                if (_passwordComplexityError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _passwordComplexityError!,
                      style: const TextStyle(
                          color: Color.fromARGB(255, 255, 136, 128),
                          fontSize: 14),
                    ),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(150, 50),
                  ),
                  onPressed: _sendVerificationEmail,
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
