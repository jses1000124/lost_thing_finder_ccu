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
  var canSeePassword = true; //Can't see

  Future<void> _signUp() async {
    final String username = _usernameController.text;
    final String account = _accountController.text;
    final String password = _passwordController.text;

    final Uri apiUrl = Uri.parse('http://25.14.26.180:5000/register');
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
        if (_passwordController.text != _confirmPasswordController.text) {
          _showAlertDialog('Failed', 'Passwords do not match');
        } else {
          _showAlertDialog('Error', 'An unexpected error occurred');
        }
      }
    });
    return;
  }

  void _clearTextFields() {
    _usernameController.clear();
    _accountController.clear();
    _passwordController.clear();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InputToLoginSignUp(
                controller: _usernameController,
                icon: const Icon(Icons.person),
                labelText: '使用者名稱'),
            const SizedBox(height: 20),
            InputToLoginSignUp(
                controller: _accountController,
                icon: const Icon(Icons.mail),
                labelText: '信箱'),
            const SizedBox(height: 20),
            TextField(
              style: const TextStyle(color: Colors.white),
              controller: _passwordController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock),
                labelText: '密碼',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                      canSeePassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      canSeePassword = !canSeePassword;
                    });
                  },
                ),
              ),
              obscureText: canSeePassword,
            ),
            const SizedBox(height: 20),
            TextField(
              style: const TextStyle(color: Colors.white),
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline),
                labelText: '確認密碼',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                      canSeePassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      canSeePassword = !canSeePassword;
                    });
                  },
                ),
              ),
              obscureText: canSeePassword,
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
    );
  }
}
