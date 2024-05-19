import 'dart:async';
import 'dart:convert';
import 'package:final_project/models/lost_thing_and_Url.dart';
import 'package:final_project/models/post_provider.dart';
import 'package:http/http.dart' as http;
import 'package:final_project/data/get_user_data.dart';
import 'package:final_project/screens/main_page.dart';
import 'package:final_project/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/show_alert_dialog.dart';

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
    if (!mounted) return; // Ensure the widget is still mounted
    final postProvider = Provider.of<PostProvider>(context, listen: false);

    bool autoLogin = prefs.getBool('autoLogin') ?? false;
    if (autoLogin) {
      String account = prefs.getString('account') ?? '';
      String password = prefs.getString('password') ?? '';

      final Uri apiUrl = Uri.parse('$basedApiUrl/login');
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
          if(!mounted) return; // Ensure the widget is still mounted
          await GetUserData().getUserData(context);
          // 等待直到 PostProvider 的数据加载完毕
          await Future.doWhile(() =>
              Future.delayed(const Duration(milliseconds: 100),
                  () => postProvider.isLoading)).then((value) => {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const BottomBar()),
                  (Route<dynamic> route) => false,
                )
              });
        } else if (mounted) {
          _handleLoginError(response.statusCode);
        }
      } catch (e) {
        if (mounted) {
          showAlertDialog('Error', 'An unexpected error occurred: $e', context,
              toLogin: true);
        }
      }
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  void _handleLoginError(int statusCode) {
    if (statusCode == 401) {
      showAlertDialog('Failed', 'Invalid password', context, toLogin: true);
    } else if (statusCode == 404) {
      showAlertDialog('Failed', 'Account not found', context, toLogin: true);
    } else {
      showAlertDialog('Error', 'An unexpected error occurred', context,
          toLogin: true);
    }
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
