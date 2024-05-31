import 'package:final_project/widgets/chat_message.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String chatID;
  final String chatUserEmail;
  final String chatUserNickname;
  final String chatUserImage;

  const ChatScreen({
    super.key,
    required this.chatID,
    required this.chatUserEmail,
    required this.chatUserNickname,
    required this.chatUserImage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(widget.chatUserNickname),
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatMessage(
                chatID: widget.chatID,
                chatNickName: widget.chatUserNickname,
                chatUserImage: widget.chatUserImage,
                chatUserEmail: widget.chatUserEmail),
          )
        ],
      ),
    );
  }
}
