import 'dart:convert';
import 'package:final_project/models/lost_thing_and_Url.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

Future<Map<String, List<dynamic>>> getNickname(List<String> emails) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  Uri url = Uri.parse('$basedApiUrl/getnickname_with_emails');

  final Map<String, dynamic> requestBody = {
    'token': token!,
    'emails': emails,
  };

  try {
    final response = await http.post(
      url,
      body: jsonEncode(requestBody),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      var body = json.decode(response.body);
      List<dynamic> nicknames = List<dynamic>.from(body['nicknames']);
      List<dynamic> userimgs = List<dynamic>.from(body['userimgs']);
      Map<String, List<dynamic>> userDataMap = Map.fromIterables(emails,
          List.generate(emails.length, (i) => [nicknames[i], userimgs[i]]));
      return userDataMap;
    } else {
      debugPrint('Failed to get nickname: HTTP status ${response.statusCode}');
      return {};
    }
  } catch (e) {
    debugPrint('Error occurred while fetching nickname: $e');
    return {};
  }
}
