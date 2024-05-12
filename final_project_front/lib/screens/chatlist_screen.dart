import 'package:cloud_firestore/cloud_firestore.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('聊天室'),
      ),
      body: FutureBuilder(
        future: _buildChatList(),
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

  Future<Widget> _buildChatList() async {
    final prefs = await _getPrefs();
    final authaccount = prefs.getString('email')!;
    
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('user')
          .doc(authaccount)
          .collection('chatlist')
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
              .map<Widget>((doc) => _buildChatItem(doc))
              .toList(),
        );
      },
    );
  }

  Widget _buildChatItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;

    if (true) {
      return ListTile(
        title: Text(
          data['name'] ?? 'No name',
          style: const TextStyle(color: Colors.white),
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ChatScreen(),
            ),
          );
        },
      );
    }
  }
}
