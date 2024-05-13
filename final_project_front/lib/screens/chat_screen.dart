import 'package:final_project/widgets/chat_message.dart';
import 'package:final_project/widgets/new_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ChatScreen extends StatefulWidget {
  final String chatID;
  final String chatNickName;
  const ChatScreen(
      {super.key, required this.chatID, required this.chatNickName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Notification function
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
        title: Text(widget.chatNickName),
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatMessage(chatID: widget.chatID, chatNickName: widget.chatNickName),
          ),
          NewMessage(chatID: widget.chatID,),
        ],
      ),
    );
  }
}
