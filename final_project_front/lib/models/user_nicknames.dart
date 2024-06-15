import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences with ChangeNotifier {
  String _nickname = '未設定';

  String get nickname => _nickname;

  void setNickname(String newNickname) {
    _nickname = newNickname;
    notifyListeners();
  }

  Future<void> loadPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _nickname = prefs.getString('nickname') ?? '未設定';
    notifyListeners();
  }

  Future<void> updateNickname(String newNickname) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('nickname', newNickname);
    setNickname(newNickname);
  }
}
