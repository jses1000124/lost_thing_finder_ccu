import 'dart:async';
import 'package:final_project/models/lost_thing_and_Url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:final_project/widgets/show_alert_dialog.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;
  String? _passwordComplexityError; // Declare the error message variable

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  String? email;
  String? token;

  Future<void> _loadPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString('email') ?? '';
    token = prefs.getString('token') ?? '';
  }

  Widget buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    required bool visible,
    required VoidCallback toggleVisibility,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !visible,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        suffixIcon: IconButton(
          icon: Icon(visible ? Icons.visibility_off : Icons.visibility),
          onPressed: toggleVisibility,
        ),
      ),
      validator: validator,
      onChanged: (value) {
        setState(() {});
        _formKey.currentState!.validate(); 
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('更改密碼'),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(48.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildPasswordField(
                  controller: _oldPasswordController,
                  label: '舊密碼',
                  visible: _passwordVisible,
                  toggleVisibility: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                  validator: (value) => value!.isEmpty ? '舊密碼不能為空' : null,
                ),
                const SizedBox(height: 16),
                buildPasswordField(
                  controller: _newPasswordController,
                  label: '新密碼',
                  visible: _passwordVisible,
                  toggleVisibility: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                  validator: (value) {
                    if (value!.isEmpty) return '新密碼不能為空';
                    if (value.length < 8 ||
                        !RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$')
                            .hasMatch(value)) {
                      _passwordComplexityError = '密碼必須有8個字符，並包含數字和字母';
                      return null;
                    }
                    _passwordComplexityError = null;
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                buildPasswordField(
                  controller: _confirmNewPasswordController,
                  label: '確認新密碼',
                  visible: _passwordVisible,
                  toggleVisibility: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                  validator: (value) {
                    if (value!.isEmpty) return '確認新密碼不能為空';
                    if (value != _newPasswordController.text) return '與新密碼不符';
                    return null;
                  },
                ),
                if (_passwordComplexityError !=
                    null) // Display the error message if it exists
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _passwordComplexityError!,
                      style: const TextStyle(
                          color: Color.fromARGB(255, 255, 141, 133),
                          fontSize: 14),
                    ),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _sendChangedPassword();
                    }
                  },
                  child: const Text(
                    '確認更改',
                    style: TextStyle(fontSize: 22),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> clearSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', '');
    await prefs.setString('token', '');
    await prefs.setString('password', '');
    await prefs.setBool('autoLogin', false);
  }

  Future<void> _sendChangedPassword() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String oldPassword = prefs.getString('password') ?? '';

    if (oldPassword != _oldPasswordController.text) {
      if (!mounted) return;
      showAlertDialog('錯誤', '舊密碼錯誤', context);
      return;
    }

    if (_oldPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmNewPasswordController.text.isEmpty) {
      if (!mounted) return;
      showAlertDialog('錯誤', '密碼不可為空', context);
      return;
    }

    if (_newPasswordController.text != _confirmNewPasswordController.text) {
      if (!mounted) return;
      showAlertDialog('錯誤', '新密碼不一致', context);
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String inputOldPassword = _oldPasswordController.text;
    final String newPassword = _newPasswordController.text;
    final Uri apiUrl = Uri.parse('$basedApiUrl/change_password');
    final Map<String, String> requestBody = {
      'token': token!,
      'identifier': email!,
      'old_password': inputOldPassword,
      'new_password': newPassword,
    };

    try {
      final response = await http.post(
        apiUrl,
        body: jsonEncode(requestBody),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (!mounted) return;

      if (response.statusCode == 200) {
        prefs.setString('password', newPassword);
        prefs.setBool('autoLogin', false);
        showAlertDialog('成功', '密碼已更改', context, success: true, toLogin: true);
      } else {
        if (response.statusCode == 401) {
          showAlertDialog('失敗', '無效的密碼', context);
        } else if (response.statusCode == 404) {
          showAlertDialog('失敗', '帳號未找到', context);
        } else {
          showAlertDialog('錯誤', '發生未預期的錯誤', context);
        }
      }
    } on TimeoutException catch (_) {
      if (!mounted) return;
      showAlertDialog('超時', '請求超時', context);
    } catch (e) {
      if (!mounted) return;
      showAlertDialog('錯誤', '發生未預期的錯誤：$e', context);
    }
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }
}
