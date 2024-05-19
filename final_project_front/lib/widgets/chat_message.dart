import 'package:final_project/data/post_notification.dart';
import 'package:final_project/data/upload_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:image_picker/image_picker.dart';

class ChatMessage extends StatefulWidget {
  final String chatID;
  final String chatNickName;
  final String chatUserImage;
  final String chatUserEmail;

  const ChatMessage({
    super.key,
    required this.chatID,
    required this.chatNickName,
    required this.chatUserImage,
    required this.chatUserEmail,
  });

  @override
  State<ChatMessage> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
  final List<types.Message> _messages = [];
  late Future<SharedPreferences> _prefs;
  String? authAccount;
  String? myNickname;
  String? myImg;
  String imageURL = '';

  @override
  void initState() {
    super.initState();
    _prefs = SharedPreferences.getInstance();
    _loadUserPrefs();
  }

  void _loadUserPrefs() async {
    final prefs = await _prefs;
    setState(() {
      authAccount = prefs.getString('email');
      myNickname = prefs.getString('nickname');
      myImg = prefs.getString('avatarid');
    });
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SizedBox(
              height: 200,
              child: Column(children: <Widget>[
                ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      _showCameraImage();
                    },
                    leading: const Icon(Icons.photo_camera),
                    title: const Text("拍攝照片")),
                ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      _showPhotoLibrary();
                    },
                    leading: const Icon(Icons.photo_library),
                    title: const Text("選擇照片"))
              ]));
        });
  }

  void _showCameraImage() async {
    ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return;
    if (!mounted) return;
    var url = await UploadImage().uploadImage(context, image.path, 'chatImage');
    setState(() {
      imageURL = url;
    });
    FirebaseFirestore.instance
        .collection('chat')
        .doc(widget.chatID)
        .collection('message')
        .add({
      'text': '',
      'createdAt': Timestamp.now(),
      'userEmail': authAccount,
      'chatID': widget.chatID,
      'imageURL': imageURL,
      'isRead': false,
    });
  }

  void _showPhotoLibrary() async {
    ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    if (!mounted) return;
    var url = await UploadImage().uploadImage(context, image.path, 'chatImage');
    setState(() {
      imageURL = url;
    });
    FirebaseFirestore.instance
        .collection('chat')
        .doc(widget.chatID)
        .collection('message')
        .add({
      'text': '',
      'createdAt': Timestamp.now(),
      'userEmail': authAccount,
      'chatID': widget.chatID,
      'imageURL': imageURL,
      'isRead': false,
    });
  }

  void _sendMessage(types.PartialText message) {
    FirebaseFirestore.instance
        .collection('chat')
        .doc(widget.chatID)
        .collection('message')
        .add({
      'userEmail': authAccount,
      'text': message.text,
      'createdAt': Timestamp.now(),
      'imageURL': '',
      'isRead': false,
    });

    FirebaseFirestore.instance.collection('chat').doc(widget.chatID).update({
      'isLastMessageImage': imageURL.isNotEmpty ? true : false,
      'lastUpdated': Timestamp.now(),
      'lastMessage': message.text,
      'readStatus.${widget.chatUserEmail.replaceAll('.', '_')}': false
    });

    sendNotification(widget.chatUserEmail, widget.chatNickName, message.text);
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );

    setState(() {
      _messages[index] = updatedMessage;
    });
  }

  List<types.Message> _mapFirestoreDataToChatMessages(
      List<DocumentSnapshot> chatDocs) {
    return chatDocs.map((doc) {
      final chatMessage = doc.data() as Map<String, dynamic>;
      final isCurrentUser = chatMessage['userEmail'] == authAccount;

      final user = types.User(
        id: chatMessage['userEmail'],
        firstName: isCurrentUser ? myNickname : widget.chatNickName,
        imageUrl: isCurrentUser ? myImg : widget.chatUserImage,
      );

      if (chatMessage['imageURL'] != null &&
          chatMessage['imageURL'].isNotEmpty) {
        return types.ImageMessage(
          author: user,
          createdAt:
              (chatMessage['createdAt'] as Timestamp).millisecondsSinceEpoch,
          id: doc.id,
          name: 'Image',
          size: 50,
          uri: chatMessage['imageURL'],
          metadata: {
            'isRead': chatMessage['isRead'] ?? false,
          },
        );
      } else {
        return types.TextMessage(
          author: user,
          createdAt:
              (chatMessage['createdAt'] as Timestamp).millisecondsSinceEpoch,
          id: doc.id,
          text: chatMessage['text'] ?? '',
          metadata: {
            'isRead': chatMessage['isRead'] ?? false,
          },
        );
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .doc(widget.chatID)
          .collection('message')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (chatSnapshot.hasError) {
          return const Center(
            child: Text('ERROR!'),
          );
        }
        if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('還沒有訊息喔！快來聊天吧！'),
          );
        }

        final chatDocs = chatSnapshot.data!.docs;
        final messages = _mapFirestoreDataToChatMessages(chatDocs);

        return Chat(
          theme: DefaultChatTheme(
            backgroundColor: Theme.of(context).colorScheme.background,
            inputBackgroundColor:
                Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ),
          hideBackgroundOnEmojiMessages: true,
          messages: messages,
          onSendPressed: (types.PartialText message) {
            _sendMessage(message);
          },
          user: types.User(
            id: authAccount ?? '',
            firstName: myNickname,
            imageUrl: myImg,
          ),
          onAttachmentPressed: () {
            _showOptions(context);
          },
          onPreviewDataFetched: _handlePreviewDataFetched,
        );
      },
    );
  }
}
