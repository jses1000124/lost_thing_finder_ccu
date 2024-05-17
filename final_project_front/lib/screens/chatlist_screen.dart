import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:final_project/data/get_nickname_and_userimage.dart';
import 'package:final_project/screens/chat_screen.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    final double size = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('聊天室'),
      ),
      body: FutureBuilder(
        future: _buildChatList(size),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return snapshot.data as Widget;
        },
      ),
    );
  }

  Future<Widget> _buildChatList(double size) async {
    final prefs = await _getPrefs();
    final authaccount = prefs.getString('email')!;

    final chatSnapshots = await FirebaseFirestore.instance
        .collection('chat')
        .where('member', arrayContains: authaccount)
        .get();

    if (chatSnapshots.docs.isEmpty) {
      return const Center(
        child: Text('還沒有訊息喔！快來聊天吧！'),
      );
    }

    List<String> memberEmails = [];

    for (var doc in chatSnapshots.docs) {
      final member = doc['member'] as List<dynamic>;
      member.removeWhere((element) => element == authaccount);
      memberEmails.add(member[0]);
    }

    Map<String, List<dynamic>> userData = await getNickname(memberEmails);

    return ListView(
      children: chatSnapshots.docs.map<Widget>((doc) {
        final member = doc['member'] as List<dynamic>;
        member.removeWhere((element) => element == authaccount);
        final memberEmail = member[0];
        final nickname = userData[memberEmail]?[0] ?? memberEmail;
        final img = userData[memberEmail]?[1] ?? 0;

        return Slidable(
          key: Key(doc.id),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (context) async {
                  final confirmed = await showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('確定要刪除此聊天室嗎？'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(ctx).pop(false);
                          },
                          child: const Text('取消'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(ctx).pop(true);
                          },
                          child: const Text('確定'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await FirebaseFirestore.instance
                        .collection('chat')
                        .doc(doc.id)
                        .delete();
                    setState(() {});
                  }
                },
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: '刪除',
              ),
            ],
          ),
          child: ListTile(
            title: Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage('assets/images/avatar_$img.png'),
                  radius: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nickname.length > 10
                            ? '${nickname.substring(0, 10)}...'
                            : nickname,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (doc['lastMessage'] != '')
                        Text(
                          '最新訊息：${doc['lastMessage'].length > 10 ? '${doc['lastMessage'].substring(0, 10)}...' : doc['lastMessage']}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    chatID: doc.id,
                    chatUserEmail: memberEmail,
                    chatUserNickname: nickname,
                    chatUserImage: img,
                  ),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }
}
