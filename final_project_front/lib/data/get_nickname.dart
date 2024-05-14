import 'dart:convert';
import 'package:final_project/models/lost_thing_and_Url.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class GetNickname {
  Future<String> getNickname(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    Uri url = Uri.parse('$basedApiUrl/getnickname_with_email');

    final Map<String, String?> requestBody = {
      'token': token,
      'email': email,
    };

    try {
      final response = await http.post(
        url,
        body: jsonEncode(requestBody),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        var body = json.decode(response.body);
        String? nickname = body['nickname'];
        return nickname!;
      } else {
        debugPrint(
            'Failed to get nickname: HTTP status ${response.statusCode}');
        return '使用者不存在或已被刪除';
      }
    } catch (e) {
      debugPrint('Error occurred while fetching nickname: $e');
      return 'NULL';
    }
  }
}
