import 'package:final_project/widgets/chat_message.dart';
import 'package:final_project/widgets/new_message.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // void setupNotifications() async {
  //   final fcm = FirebaseMessaging.instance;
  //   await fcm.requestPermission();
  //   final token = await fcm.getToken();
  //   print(token);
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   setupNotifications();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('聊天室'),
      ),
      body: const Column(
        children: [
          Expanded(
            child: ChatMessage(),
          ),
          NewMessage(),
        ],
      ),
    );
  }
}
