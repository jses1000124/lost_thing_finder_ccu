import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:final_project/data/get_user_data.dart';
import 'package:final_project/screens/bottom_bar.dart';
import 'package:final_project/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AutoLoginHandler extends StatefulWidget {
  const AutoLoginHandler({super.key});

  @override
  State<AutoLoginHandler> createState() => _AutoLoginHandlerState();
}

class _AutoLoginHandlerState extends State<AutoLoginHandler> {
  @override
  void initState() {
    super.initState();
    _checkAndLogin();
  }

  Future<void> _checkAndLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool autoLogin = prefs.getBool('autoLogin') ?? false;

    if (autoLogin) {
      String account = prefs.getString('account') ?? '';
      String password = prefs.getString('password') ?? '';

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
        ).timeout(const Duration(seconds: 5)); // Set a 5-second timeout

        if (response.statusCode == 200 && mounted) {
          await prefs.setString('token', jsonDecode(response.body)['token']);
          await GetUserData().getUserData(context).then((value) {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const BottomBar()));
          });
        } else if (mounted) {
          _handleLoginError(response.statusCode);
        }
      } on TimeoutException catch (_) {
        if (mounted) {
          _showAlertDialog('Timeout', 'Request timed out');
        }
      } catch (e) {
        if (mounted) {
          _showAlertDialog('Error', 'An unexpected error occurred: $e');
        }
      }
    } else if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false);
    }
  }

  void _handleLoginError(int statusCode) {
    if (statusCode == 401) {
      _showAlertDialog('Failed', 'Invalid password');
    } else if (statusCode == 404) {
      _showAlertDialog('Failed', 'Account not found');
    } else {
      _showAlertDialog('Error', 'An unexpected error occurred');
    }
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(Icons.error,
              color: Color.fromARGB(255, 255, 97, 149), size: 60),
          title: Text(title,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center),
          content: Text(message,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                SharedPreferences.getInstance().then((prefs) {
                  prefs.remove('token');
                  prefs.remove('autoLogin');
                  prefs.remove('account');
                  prefs.remove('password');
                });
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const LoginScreen()));
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Showing a loader while we check for auto login
    return FutureBuilder(
      future: _checkAndLogin(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
