import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('chat').snapshots(),
      builder: (ctx, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if(!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty){
          return const Center(
            child: Text('No chat messages yet! Start chatting!'),
          );
        }

        if(chatSnapshot.hasError){
          return const Center(
            child: Text('An error occurred!'),
          );
        }

        final chatDocs = chatSnapshot.data!.docs;
        return ListView.builder(
          itemCount: chatDocs.length,
          itemBuilder: (ctx, index) => Text(
            chatDocs[index].data()['text']),
        ); 
      },
    );

  }

}
