import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:email_validator/email_validator.dart';
import '../models/lost_thing_and_Url.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key, required this.token});
  final String token;

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var canSeePassword = true;

  String? _passwordError;

  Future<void> _confirmDeleteAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('確認刪除'),
          content: const Text('您確定要刪除您的帳號嗎？\n這個操作無法撤銷。'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAccount();
              },
              child: const Text('確認'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String password = _passwordController.text;
    final String email = _emailController.text;
    final String token = widget.token;
    final Uri apiUrl = Uri.parse('${basedApiUrl}/delete_account');
    final Map<String, String> requestBody = {
      'account': email,
      'password': password,
      'token': token,
    };

    try {
      final response = await http.post(
        apiUrl,
        body: jsonEncode(requestBody),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('chat')
            .where('member', arrayContains: email)
            .get();

        for (var doc in querySnapshot.docs) {
          // Delete user's chat data
          await FirebaseFirestore.instance
              .collection('chat')
              .doc(doc.id)
              .delete();

          // Delete chat images from Firebase Storage
          final ListResult result = await FirebaseStorage.instance
              .ref('chatImage/${doc.id}')
              .listAll();

          // 刪除資料夾中的所有文件
          for (var fileRef in result.items) {
            await fileRef.delete();
          }
        }

        // Delete user's lost things img
        final ListResult result =
            await FirebaseStorage.instance.ref('lostThing/${email}').listAll();
        for (var fileRef in result.items) {
          await fileRef.delete();
        }

        if (mounted) {
          showAlertDialog('成功', '帳號已刪除', context);
        }
      } else {
        if (mounted) {
          showAlertDialog('失敗', '請稍後再試', context);
        }
      }
    } on TimeoutException {
      if (mounted) {
        showAlertDialog('失敗', '請稍後再試', context);
      }
    } catch (e) {
      if (mounted) {
        showAlertDialog('錯誤', '發生未預期的錯誤\n${e}', context);
      }
    }
  }

  void showAlertDialog(String title, String message, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('確定'),
            ),
          ],
        );
      },
    );
  }

  void _validateForm() {
    _formKey.currentState!.validate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('刪除帳號'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelText: '電子郵件',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '請輸入電子郵件';
                  } else if (!EmailValidator.validate(value)) {
                    return '請輸入有效的電子郵件';
                  }
                  return null;
                },
                onChanged: (value) {
                  _validateForm();
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelText: '密碼',
                  errorText: _passwordError,
                  suffixIcon: IconButton(
                    icon: Icon(
                      canSeePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        canSeePassword = !canSeePassword;
                      });
                    },
                  ),
                ),
                obscureText: canSeePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '請輸入密碼';
                  }
                  return null;
                },
                onChanged: (value) {
                  _validateForm();
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _confirmDeleteAccount,
                    child: const Text('刪除帳號'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('取消'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
