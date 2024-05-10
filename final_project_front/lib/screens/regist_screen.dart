import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_screen.dart';
import 'package:final_project/widgets/user_input_login_signup.dart';

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
  final _formKey = GlobalKey<FormState>();
  var canSeePassword = true;

  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  void _validateUsername(String value) {
    setState(() {
      if (value.isEmpty) {
        _usernameError = 'Username is required';
      } else {
        _usernameError = null;
      }
    });
  }

  void _validateEmail(String value) {
    setState(() {
      if (value.isEmpty) {
        _emailError = 'Email is required';
      } else {
        // Add additional email validation logic if needed
        _emailError = null;
      }
    });
  }

  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _passwordError = 'Password is required';
      } else {
        _passwordError = null;
      }
    });
  }

  void _validateConfirmPassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _confirmPasswordError = 'Confirm Password is required';
      } else if (value != _passwordController.text) {
        _confirmPasswordError = 'Passwords do not match';
      } else {
        _confirmPasswordError = null;
      }
    });
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String username = _usernameController.text;
    final String account = _accountController.text;
    final String password = _passwordController.text;

    final Uri apiUrl = Uri.parse('http://140.123.101.199:5000/register');
    final Map<String, String> requestBody = {
      'account': account,
      'password': password,
      'username': username,
    };

    await http.post(apiUrl,
        body: jsonEncode(requestBody),
        headers: {'Content-Type': 'application/json'}).then((response) {
      if (response.statusCode == 201) {
        _showAlertDialog('Success', 'Account created successfully',
            isRegister: true);
      } else if (response.statusCode == 400) {
        _clearTextFields();
        _showAlertDialog('Failed', 'Account already exists');
      } else {
        _showAlertDialog('Error', 'An unexpected error occurred');
      }
    });
  }

  void _clearTextFields() {
    _usernameController.clear();
    _accountController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
  }

  void _showAlertDialog(String title, String message,
      {bool isRegister = false}) {
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
                    labelText: '使用者名稱',
                    errorText: _usernameError,
                    onChanged: _validateUsername),
                const SizedBox(height: 20),
                InputToLoginSignUp(
                    controller: _accountController,
                    icon: const Icon(Icons.mail),
                    labelText: '信箱',
                    errorText: _emailError,
                    onChanged: _validateEmail),
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
                const SizedBox(height: 20),
                TextFormField(
                  style: const TextStyle(color: Colors.white),
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
                    const Text('已有帳號?',
                        style: TextStyle(color: Colors.white, fontSize: 18)),
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
