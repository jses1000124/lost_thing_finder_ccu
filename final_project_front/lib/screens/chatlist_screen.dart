import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/data/get_nickname.dart';
import 'package:final_project/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .where('member', arrayContains: authaccount)
          .snapshots(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('還沒有訊息喔！快來聊天吧！'),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('ERROR!'),
          );
        }

        return ListView(
          children: snapshot.data!.docs
              .map<Widget>((doc) => FutureBuilder<Widget>(
                    future: _buildChatItem(doc, authaccount, size),
                    builder: (ctx, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return snapshot.data as Widget;
                    },
                  ))
              .toList(),
        );
      },
    );
  }

  Future<Widget> _buildChatItem(
      DocumentSnapshot doc, String authaccount, double size) async {
    // Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
    final chatID = doc.id;
    final member = doc['member'] as List<dynamic>;
    member.removeWhere((element) => element == authaccount);
    final nickname = await GetNickname().getNickname(member[0]);

    return ListTile(
      title: Row(
        children: [
          const Icon(
            Icons.account_circle,
            size: 60,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: size * 0.7,
                child: Text(
                  nickname.length > 10
                      ? '${nickname.substring(0, 10)}...'
                      : nickname,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                ),
              ),
              if (doc['lastMessage'] != '')
                SizedBox(
                  width: size * 0.7,
                  child: Text(
                    '最新訊息：${doc['lastMessage'].length > 10 ? '${doc['lastMessage'].substring(0, 10)}...' : doc['lastMessage']}',
                    maxLines: 1,
                  ),
                ),
            ],
          ),
        ],
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                ChatScreen(chatID: chatID, chatUserEmail: member[0]),
          ),
        );
      },
    );
  }
}
