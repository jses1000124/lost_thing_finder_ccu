import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/data/post_notification.dart';
import 'package:final_project/data/upload_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewMessage extends StatefulWidget {
  final String chatID;
  final String chatUserEmail;

  const NewMessage(
      {super.key, required this.chatID, required this.chatUserEmail});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _messagecontroller = TextEditingController();
  String imageURL = '';

  String _sanitizeEmail(String email) {
    return email.replaceAll('.', '_');
  }

  @override
  void dispose() {
    _messagecontroller.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    final enteredMessage = _messagecontroller.text;
    final sanitizechatUserEmail = _sanitizeEmail(widget.chatUserEmail);

    if (enteredMessage.trim().isEmpty && imageURL.isEmpty) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('email')!;
    OneSignal.login(userEmail);

    FirebaseFirestore.instance
        .collection('chat')
        .doc(widget.chatID)
        .collection('message')
        .add({
      'text': enteredMessage,
      'createdAt': Timestamp.now(),
      'userEmail': userEmail,
      'chatID': widget.chatID,
      'imageURL': imageURL,
    });

    FirebaseFirestore.instance.collection('chat').doc(widget.chatID).update({
      'isLastMessageImage': imageURL.isNotEmpty ? true : false,
      'lastUpdated': Timestamp.now(),
      'lastMessage': enteredMessage,
      'readStatus.$sanitizechatUserEmail': false
    });

    _messagecontroller.clear();

    sendNotification(widget.chatUserEmail, enteredMessage, userEmail);
  }

  void _showCameraImage() async {
    ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return;
    if (!mounted) return;
    imageURL =
        await UploadImage().uploadImage(context, image.path, 'chatImage');

    _submitMessage();
  }

  void _showPhotoLibrary() async {
    ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    if (!mounted) return;
    imageURL =
        await UploadImage().uploadImage(context, image.path, 'chatImage');

    _submitMessage();
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
                  _showCameraImage();
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
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: '輸 入 訊 息 . . .',
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? const Color.fromARGB(255, 84, 84, 84)
                    : Colors.white,
                filled: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 1, horizontal: 10),
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
