import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

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
    FirebaseFirestore.instance.collection('chat').add({
      'text': enteredMessage,
      'createdAt': Timestamp.now(),
      'userId': prefs.getString('nickname'),
    });

    _messagecontroller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              padding: const EdgeInsets.only(bottom: 10),
              child: TextField(
                controller: _messagecontroller,
                enableSuggestions: true,
                autocorrect: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Send a message...',
                  fillColor: const Color.fromARGB(255, 84, 84, 84),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(20.0), // Set the border radius
                    borderSide: BorderSide.none, // Remove the border
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            padding: const EdgeInsets.only(bottom: 10),
            icon: const Icon(Icons.send),
            onPressed: _submitMessage,
          )
        ],
      ),
    );
  }
}
