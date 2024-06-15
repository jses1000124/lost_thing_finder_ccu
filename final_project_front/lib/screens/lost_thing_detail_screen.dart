import 'dart:async';
import 'package:final_project/data/create_new_room.dart';
import 'package:final_project/data/get_nickname_and_userimage.dart';
import 'package:final_project/data/reference_post.dart';
import 'package:final_project/models/lost_thing_and_Url.dart';
import 'package:final_project/screens/chat_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'edit_post_screen.dart';
import 'package:final_project/models/post_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/show_alert_dialog.dart';
import '../widgets/show_loading_dialog.dart';
import 'post_in_map_screen.dart';

class LostThingDetailScreen extends StatefulWidget {
  final LostThing lostThings;
  const LostThingDetailScreen({super.key, required this.lostThings});

  @override
  State<LostThingDetailScreen> createState() => _LostThingState();
}

class _LostThingState extends State<LostThingDetailScreen>
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
          content: const Text('你確定要刪除這個貼文嗎？'),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('刪除'),
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
      if (!mounted) return;
      Navigator.of(context).pop(); 

      if (code == 200) {
        // Delete the image from Firebase Storage
        if (widget.lostThings.imageUrl.isNotEmpty) {
          await FirebaseStorage.instance
              .refFromURL(widget.lostThings.imageUrl)
              .delete();
        }

        showAlertDialog('成功', '貼文已刪除', context, success: true, popTwice: true);
      } else if (code == 404) {
        Navigator.of(context).pop(); 
        showAlertDialog('錯誤', '貼文未找到', context);
      } else if (code == 403) {
        Navigator.of(context).pop(); 
        showAlertDialog('錯誤', '權限不足', context);
      } else if (code == 408) {
        Navigator.of(context).pop(); 
        showAlertDialog('錯誤', '請求超時', context);
      } else {
        Navigator.of(context).pop(); 
        showAlertDialog('錯誤', '發生錯誤：$code', context);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); 
      showAlertDialog('錯誤', '發生錯誤：$e', context);
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
        title: Text(lostThings.mylosting == 1 ? '尋找失物' : '發現失物'),
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
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(
                      'assets/images/avatar_${lostThings.headShotIndex}.png'),
                  radius: 16,
                ),
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
                Flexible(
                  child: TextButton(
                    child: Text(
                      lostThings.location,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium!.copyWith(
                        color: const Color.fromARGB(255, 171, 202, 255),
                      ),
                      softWrap: true,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => PostMapPage(
                            lostThing: lostThings,
                          ),
                        ),
                      );
                    },
                  ),
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
                      child: CachedNetworkImage(
                        imageUrl: lostThings.imageUrl,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                        fit: BoxFit.cover,
                        cacheKey: lostThings.imageUrl,
                        cacheManager: CacheManager(
                          Config(
                            'customCacheKey',
                            stalePeriod: const Duration(days: 2),
                            maxNrOfCacheObjects: 100,
                          ),
                        ),
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
    String? chatID = await createNewChatRoom(postUserEmail, authEmail);
    if (!mounted) return; // Check if mounted before using context
    List<dynamic> data = (await getNickname([postUserEmail]))[postUserEmail]!;
    String nickname = data[0];
    String chatUserImage = data[1];

    referencePost(chatID, authEmail, widget.lostThings);

    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (ctx) => ChatScreen(
        chatID: chatID,
        chatUserEmail: postUserEmail,
        chatUserNickname: nickname,
        chatUserImage: chatUserImage,
      ),
    ));
  }
}
