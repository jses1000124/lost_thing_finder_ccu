import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/screens/chat_screen.dart';
import 'package:flutter/material.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('聊天室'),
      ),
      body: _buildChatList(context),
    );
  }

  Widget _buildChatList(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('user').snapshots(),
        builder: (ctx, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!userSnapshot.hasData || userSnapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('還沒有訊息喔！快來聊天吧！'),
            );
          }

          if (userSnapshot.hasError) {
            return const Center(
              child: Text('ERROR!'),
            );
          }

          final userDocs = userSnapshot.data!.docs ;
          return ListView.builder(
            reverse: true,
            padding: const EdgeInsets.all(10.0),
            itemCount: userDocs.length,
            itemBuilder: (ctx, index) {
              final user = userDocs[index].data();
              return ListTile(
                title: Text(user['name']),
                subtitle: Text(user['email']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChatScreen()),
                  );
                },
              );
            },
          );
        });
  }
}
