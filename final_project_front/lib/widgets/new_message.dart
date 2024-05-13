import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewMessage extends StatefulWidget {
  final String chatID;
  const NewMessage({super.key, required this.chatID});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _messagecontroller = TextEditingController();

  @override
  void dispose() {
    _messagecontroller.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    final enteredMessage = _messagecontroller.text;
    if (enteredMessage.trim().isEmpty) {
      return;
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    FirebaseFirestore.instance
        .collection('chat')
        .doc(widget.chatID)
        .collection('message')
        .add({
      'text': enteredMessage,
      'createdAt': Timestamp.now(),
      'userEmail': prefs.getString('email'),
      'chatID': widget.chatID,
    });
    FirebaseFirestore.instance.collection('chat').doc(widget.chatID).update(
        {'lastUpdated': Timestamp.now(), 'lastMessage': enteredMessage});
    _messagecontroller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 20, right: 10, bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messagecontroller,
              enableSuggestions: true,
              autocorrect: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: '輸 入 訊 息 . . .',
                fillColor: const Color.fromARGB(255, 84, 84, 84),
                filled: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(20.0), // Set the border radius
                  borderSide: BorderSide.none, // Remove the border
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _submitMessage,
          )
        ],
      ),
    );
  }
}
