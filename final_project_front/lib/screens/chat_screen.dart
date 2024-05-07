import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              children: const [
                ListTile(
                  title: Text('Hello'),
                ),
                ListTile(
                  title: Text('World'),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              ElevatedButton(
                child: const Text('Send'),
                onPressed: () { },
              ),
            ],
          ),
        ],
      ),
    );
  }
}