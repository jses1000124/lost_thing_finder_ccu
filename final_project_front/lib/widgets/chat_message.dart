import 'package:final_project/widgets/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatMessage extends StatelessWidget {
  final String chatID;
  final String chatNickName;
  const ChatMessage(
      {super.key, required this.chatID, required this.chatNickName});

  Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    String authaccount = '';
    String myNickname = '';
    _getPrefs().then((prefs) {
      authaccount = prefs.getString('email')!;
      myNickname = prefs.getString('nickname')!;
    });

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .doc(chatID)
          .collection('message')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('還沒有訊息喔！快來聊天吧！'),
          );
        }

        if (chatSnapshot.hasError) {
          return const Center(
            child: Text('ERROR!'),
          );
        }

        final chatDocs = chatSnapshot.data!.docs;
        return ListView.builder(
          reverse: true,
          padding: const EdgeInsets.all(10.0),
          itemCount: chatDocs.length,
          itemBuilder: (ctx, index) {
            final chatMessage = chatDocs[index].data();
            final nextChatMessage =
                index + 1 < chatDocs.length ? chatDocs[index + 1].data() : null;

            final currentUser = chatMessage['userEmail'];
            final nextUser =
                nextChatMessage != null ? nextChatMessage['userEmail'] : null;

            final nextUserIsSame = currentUser == nextUser;
            final currentUserNickname =
                currentUser == authaccount ? myNickname : chatNickName;

            if (nextUserIsSame) {
              return MessageBubble.next(
                message: chatMessage['text'],
                isMe: currentUser == authaccount,
              );
            } else {
              return MessageBubble.first(
                userImage:
                    'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
                username: currentUserNickname,
                message: chatMessage['text'],
                isMe: currentUser == authaccount,
              );
            }
          },
        );
      },
    );
  }
}
