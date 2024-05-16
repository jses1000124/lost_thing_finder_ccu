import 'package:final_project/data/get_nickname.dart';
import 'package:final_project/widgets/chat_message.dart';
import 'package:final_project/widgets/new_message.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String chatID;
  final String chatUserEmail;

  const ChatScreen(
      {super.key, required this.chatID, required this.chatUserEmail});

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
    return FutureBuilder(
      future: chatScreen(context),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return snapshot.data as Widget;
      },
    );
  }

  Future<Widget> chatScreen(BuildContext context) async {
    String chatNickName = await getNickname(widget.chatUserEmail);

    return Scaffold(
      appBar: AppBar(
        title: Text(chatNickName),
      ),
      body: Column(
        children: [
          Expanded(
            child:
                ChatMessage(chatID: widget.chatID, chatNickName: chatNickName),
          ),
          NewMessage(
            chatID: widget.chatID,
          ),
        ],
      ),
    );
  }
}
