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
        title: const Text('Chat List'),
      ),
      body: ListView(
        children: [
          Card(
            child: InkWell(
              onTap: () {},
              child: const ListTile(
                title: Text('User 1'),
              ),
            ),
          ),
          Card(
            child: InkWell(
              onTap: () {},
              child: const ListTile(
                title: Text('User 2'),
              ),
            ),
          )
        ],
      ),
    );
  }
}
