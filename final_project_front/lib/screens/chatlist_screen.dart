import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:final_project/data/get_nickname_and_userimage.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  String? authaccount;

  Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  String _sanitizeEmail(String email) {
    return email.replaceAll('.', '_');
  }

  @override
  void initState() {
    super.initState();
    _getPrefs().then((prefs) {
      setState(() {
        authaccount = prefs.getString('email');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('聊天室'),
      ),
      body: authaccount == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chat')
                  .where('member', arrayContains: authaccount)
                  .orderBy('lastUpdated', descending: true)
                  .snapshots(),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('還沒有訊息喔！快來聊天吧！'));
                }

                return FutureBuilder<Map<String, List<dynamic>>>(
                  future: getNickname(
                    snapshot.data!.docs.map((doc) {
                      final members = (doc['member'] as List<dynamic>)
                          .map((e) => e as String)
                          .toList();
                      members.remove(authaccount);
                      return members.first;
                    }).toList(),
                  ),
                  builder: (ctx, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!userSnapshot.hasData) {
                      return const Center(child: Text('獲取用戶資料失敗'));
                    }

                    final userData = userSnapshot.data!;

                    return ListView(
                      children: snapshot.data!.docs.map<Widget>((doc) {
                        final members = (doc['member'] as List<dynamic>);
                        members.remove(authaccount);
                        final memberEmail = members.first;
                        final nickname =
                            userData[memberEmail]?[0] ?? memberEmail;
                        final img = userData[memberEmail]?[1] ?? '0';
                        final isRead = (doc['readStatus'] as Map<String,
                                dynamic>)[_sanitizeEmail(authaccount!)] ??
                            true;

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
                                  backgroundImage: AssetImage(
                                      'assets/images/avatar_$img.png'),
                                  radius: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nickname.length > 10
                                            ? '${nickname.substring(0, 10)}...'
                                            : nickname,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                                      .colorScheme
                                                      .brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      if (doc['lastMessage'] != '')
                                        Text(
                                          '${doc['lastMessage'].length > 10 ? '${doc['lastMessage'].substring(0, 10)}...' : doc['lastMessage']}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: isRead
                                              ? const TextStyle(
                                                  color: Colors.grey)
                                              : const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                        )
                                      else if (doc['isLastMessageImage'])
                                        Text(
                                          '圖片',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: isRead
                                              ? const TextStyle(
                                                  color: Colors.grey)
                                              : const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (!isRead)
                                  const Icon(
                                    Icons.brightness_1,
                                    color: Colors.blue,
                                    size: 12,
                                  ),
                              ],
                            ),
                            onTap: () async {
                              if (context.mounted) {
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
                              }
                            },
                          ),
                        );
                      }).toList(),
                    );
                  },
                );
              },
            ),
    );
  }
}
