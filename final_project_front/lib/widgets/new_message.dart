import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  Future<String> _showCameraLibrary() async {
    ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return Future.value('');

    return image.path;
  }

  Future<String> _showPhotoLibrary() async {
    ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return Future.value('');

    return image.path;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 5, right: 5, bottom: 10),
      child: Row(
        children: [
          ButtonBar(
            buttonPadding: EdgeInsets.zero,
            children: [
              IconButton(
                icon: const Icon(Icons.camera_alt),
                onPressed: () {
                  _showCameraLibrary();
                },
              ),
              IconButton(
                icon: const Icon(Icons.photo),
                onPressed: () {
                  _showPhotoLibrary();
                },
              ),
            ],
          ),
          const SizedBox(width: 5), // Add this lin
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
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
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
