import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserImgIdProvider with ChangeNotifier {
  String _userImgId = '0';

  String get userImgId => _userImgId;

  Future<void> loadUserImgId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _userImgId = prefs.getString('avatarid') ?? '0';
    notifyListeners();
  }

  Future<void> updateUserImgId(String newUserImgId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('avatarid', newUserImgId);
    _userImgId = newUserImgId;
    notifyListeners();
  }
}
