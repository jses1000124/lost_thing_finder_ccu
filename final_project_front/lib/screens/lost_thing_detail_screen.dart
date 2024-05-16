import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:final_project/models/lost_thing_and_Url.dart';
import 'package:final_project/data/create_new_room.dart';
import 'package:final_project/screens/chat_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LostThingDetailScreen extends StatefulWidget {
  final LostThing lostThings;
  const LostThingDetailScreen({super.key, required this.lostThings});

  @override
  State<LostThingDetailScreen> createState() => _LostThing();
}

class _LostThing extends State<LostThingDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Future<String?> _authEmailFuture;
  late String? _token;
  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
    _authEmailFuture = _getAuthEmail();
    _loadToken();
  }

  Future<String?> _getAuthEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  Future<void> _loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 用戶不能通過點擊外部來關閉對話框
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20), // 提供一些水平空間
                Text("正在處理...", style: TextStyle(fontSize: 16)), // 顯示加載信息
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _deletePosts() async {
    final Uri apiUrl = Uri.parse('$basedApiUrl/delete_post');
    final Map<String, Object?> requestBody = {
      'token': _token,
      'id': widget.lostThings.id,
    };

    try {
      _showLoadingDialog();
      await http
          .post(apiUrl,
              body: jsonEncode(requestBody),
              headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 5)) // 設定超時時間
          .then((response) {
            if (response.statusCode == 200) {
              _showAlertDialog('成功', '貼文以刪除', isRegister: true, popThird: true);
            } else if (response.statusCode == 400) {
              _showAlertDialog('失敗', '貼文不存在', popTwice: true);
            } else {
              _showAlertDialog('錯誤', '請稍後再試', popTwice: true);
            }
          });
    } on TimeoutException catch (_) {
      _showAlertDialog('超時', '註冊請求超時', popTwice: true);
    } catch (e) {
      _showAlertDialog('錯誤', '未知錯誤：$e', popTwice: true);
    }
  }

  void _showAlertDialog(String title, String message,
      {bool isRegister = false, bool popThird = false, bool popTwice = false}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: isRegister
              ? const Icon(Icons.check, color: Colors.green, size: 60)
              : const Icon(Icons.error,
                  color: Color.fromARGB(255, 255, 97, 149), size: 60),
          title: Text(title,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center),
          content: Text(message,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center),
          actions: [
            TextButton(
              child: const Text(
                'OK',
              ),
              onPressed: () {
                if (popThird) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                } else if (popTwice) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
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
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _authEmailFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          String authEmail = snapshot.data!;
          return _buildUI(context, authEmail);
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildUI(BuildContext context, String authEmail) {
    final LostThing lostThings = widget.lostThings;
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(lostThings.mylosting == 1 ? '尋找主人的物品' : '主人丟失的物品'),
        actions: [
          if (authEmail == lostThings.postUserEmail)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {},
            ),
          if (authEmail == lostThings.postUserEmail)
            IconButton(
              icon: const Icon(FontAwesomeIcons.trashCan,
                  color: Color.fromARGB(255, 255, 145, 137)),
              onPressed: _deletePosts,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lostThings.lostThingName,
              style: theme.textTheme.titleLarge!.copyWith(
                fontSize: 38,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(
                      'assets/images/avatar_${lostThings.headShotIndex}.png'),
                  radius: 16,
                ),
                // Space between avatar and name
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lostThings.postUser,
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      lostThings.formattedDate,
                      style: theme.textTheme.titleSmall!.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    )
                  ],
                ),
                const Spacer(),
                Icon(Icons.location_on, color: theme.colorScheme.secondary),
                Text(
                  lostThings.location,
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 20),
            Text(
              lostThings.content,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            Center(
              child: lostThings.imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: FadeInImage(
                        placeholder: MemoryImage(kTransparentImage),
                        image: NetworkImage(lostThings.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
      floatingActionButton: authEmail != lostThings.postUserEmail
          ? ScaleTransition(
              scale: _animation,
              child: FloatingActionButton(
                onPressed: () => _handleMessageButtonPressed(
                    context, authEmail, lostThings.postUserEmail),
                child: const Icon(Icons.message),
              ),
            )
          : null,
    );
  }

  void _handleMessageButtonPressed(
      BuildContext context, String authEmail, String postUserEmail) async {
    String? chatID =
        await CreateNewChatRoom().createNewChatRoom(postUserEmail, authEmail);
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (ctx) =>
          ChatScreen(chatID: chatID, chatUserEmail: postUserEmail),
    ));
  }
}
