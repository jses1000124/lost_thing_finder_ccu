import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_nicknames.dart';

class GetUserData {
  Future<void> getUserData(BuildContext context) async {
    debugPrint("Getting user data...");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? account = prefs.getString('account');
    String? token = prefs.getString('token');

    if (account == null || token == null) {
      debugPrint("Account or Token is null. Please login again.");
      return;
    }

    var url = Uri.parse('http://140.123.101.199:5000/getuserdata');

    final Map<String, String> requestBody = {
      'account': account,
      'token': token,
    };

    try {
      final response = await http.post(
        url,
        body: jsonEncode(requestBody),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        var body = json.decode(response.body);
        String? username = body['username'];
        String? nickname = body['nickname'];
        String? returnedAccount = body['email'];

        if (username != null) {
          await prefs.setString('username', username);
        } else {
          debugPrint("Username is null in the response");
        }

        if (nickname != null) {
          await prefs.setString('nickname', nickname).then((value) {
            UserPreferences().loadPreferences();
            Provider.of<UserPreferences>(context, listen: false)
                .loadPreferences();
          });
        } else {
          debugPrint("Nickname is null in the response");
        }

        if (returnedAccount != null) {
          await prefs.setString('email', returnedAccount);
        } else {
          debugPrint("Account is null in the response");
        }
      } else {
        debugPrint(
            "Failed to get user data: HTTP status ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error occurred while fetching user data: $e");
    }
  }
}
