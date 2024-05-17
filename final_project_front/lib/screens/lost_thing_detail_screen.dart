import 'dart:async';
import 'edit_post_screen.dart';
import 'package:final_project/models/post_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:final_project/models/lost_thing_and_Url.dart';
import 'package:final_project/data/create_new_room.dart';
import 'package:final_project/screens/chat_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/show_alert_dialog.dart';
import '../widgets/show_loading_dialog.dart';

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

  Future<void> _confirmDeletePosts() async {
    bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('確認刪除'),
          content: const Text('確定要刪除嗎？'),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('確定'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      _deletePosts();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _deletePosts() async {
    final postProvider = Provider.of<PostProvider>(context, listen: false);

    try {
      showLoadingDialog(context);
      int code = await postProvider.deletePost(widget.lostThings.id, _token!);
      if (!mounted) return; // Check again after the asynchronous operation
      Navigator.of(context).pop(); // Close the loading dialog

      if (code == 200) {
        showAlertDialog('成功', '貼文已刪除', context, success: true, popTwice: true);
      } else if (code == 404) {
        showAlertDialog('錯誤', '貼文不存在', context);
      } else if (code == 403) {
        showAlertDialog('錯誤', '你不是發文者', context);
      } else if (code == 408) {
        showAlertDialog('錯誤', '請求超時', context);
      } else {
        showAlertDialog('錯誤', '未知錯誤：$code', context);
      }
    } catch (e) {
      if (!mounted) return; // Check again if an exception occurs
      Navigator.of(context).pop(); // Close the loading dialog
      showAlertDialog('錯誤', '未知錯誤：$e', context);
    }
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
          return const CircularProgressIndicator();
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
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (ctx) => EditPostPage(lostThing: lostThings),
                ));
              },
            ),
          if (authEmail == lostThings.postUserEmail)
            IconButton(
              icon: const Icon(FontAwesomeIcons.trashCan,
                  color: Color.fromARGB(255, 255, 145, 137)),
              onPressed: _confirmDeletePosts,
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
                    Text(lostThings.postUser,
                        style: theme.textTheme.titleMedium),
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
    await createNewChatRoom(postUserEmail, authEmail).then(
        (chatID) => Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (ctx) =>
                  ChatScreen(chatID: chatID, chatUserEmail: postUserEmail),
            )));
  }
}
