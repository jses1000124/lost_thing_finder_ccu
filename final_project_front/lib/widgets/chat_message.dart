import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:final_project/data/post_notification.dart';
import 'package:final_project/data/upload_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/post_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import '../models/lost_thing_and_Url.dart';

import '../screens/lost_thing_detail_screen.dart';

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
                if (!kIsWeb)
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
    var url = await uploadCameraImage(context, 'chatImage/${widget.chatID}');
    setState(() {
      imageURL = url;
    });
    types.PartialText message = const types.PartialText(
      text: '',
    );
    _sendMessage(message, imageURL: imageURL);
  }

  void _showPhotoLibrary() async {
    String? imageURL = '';
    if (kIsWeb) {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.image);
      if (result == null) {
        print("not get image file");
        return;
      }
      await uploadImageWeb(
              context, 'chatImage/${widget.chatID}', result.files.single.bytes!)
          .then((value) {
        imageURL = value;
      });
    } else {
      await uploadImageOther(context, 'chatImage/${widget.chatID}')
          .then((value) {
        imageURL = value;
      });
    }

    types.PartialText message = const types.PartialText(
      text: '',
    );

    _sendMessage(message, imageURL: imageURL!);
  }

  void _sendMessage(types.PartialText message, {required String imageURL}) {
    FirebaseFirestore.instance
        .collection('chat')
        .doc(widget.chatID)
        .collection('message')
        .add({
      'userEmail': authAccount,
      'text': message.text,
      'createdAt': Timestamp.now(),
      'imageURL': imageURL,
      'isRead': false,
    });

    FirebaseFirestore.instance.collection('chat').doc(widget.chatID).update({
      'isLastMessageImage': imageURL.isNotEmpty ? true : false,
      'lastUpdated': Timestamp.now(),
      'lastMessage': message.text,
      'readStatus.${widget.chatUserEmail.replaceAll('.', '_')}': false
    });

    sendNotification(widget.chatUserEmail, myNickname!,
        imageURL.isNotEmpty ? '📷 圖片' : message.text);
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

      if (chatMessage['type'] == 'custom') {
        return types.CustomMessage(
          author: user,
          createdAt:
              (chatMessage['createdAt'] as Timestamp).millisecondsSinceEpoch,
          id: doc.id,
          metadata: {
            'type': 'info',
            'postID': chatMessage['postID'] ?? '',
          },
        );
      } else if (chatMessage['imageURL'] != null &&
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
            'type': chatMessage['type'],
          },
        );
      }
    }).toList();
  }

  Widget _buildCustomMessage(types.CustomMessage message,
      {required int messageWidth}) {
    if (message.metadata != null && message.metadata!['type'] == 'info') {
      String postID = message.metadata!['postID'];

      PostProvider postProvider = Provider.of<PostProvider>(context);
      LostThing? post = postProvider.posts.firstWhere(
          (element) => element.id.toString() == postID,
          orElse: () => LostThing(
              lostThingName: '已刪除的貼文',
              content: '已刪除的貼文',
              date: DateTime.now(),
              postUser: '已刪除的貼文',
              postUserEmail: '已刪除的貼文',
              imageUrl: '',
              location: '已刪除的貼文',
              mylosting: 0,
              id: -1,
              latitude: 0,
              longitude: 0));

      return InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => LostThingDetailScreen(
                    lostThings: post,
                  )));
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              post.imageUrl != ''
                  ? Container(
                      width: 100,
                      height: 100,
                      // padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(post.imageUrl),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    )
                  : const SizedBox(width: 150),
              SizedBox(width: 10),
              Expanded(
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.lostThingName,
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      Divider(color: Colors.white),
                      Row(
                        children: [
                          Icon(Icons.location_on),
                          SizedBox(width: 5),
                          Text(
                            post.location,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.date_range),
                          SizedBox(width: 5),
                          Text(
                            post.formattedDate,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return const SizedBox();
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

        final chatDocs = chatSnapshot.data!.docs;
        final messages = _mapFirestoreDataToChatMessages(chatDocs);

        return Chat(
          theme: DefaultChatTheme(
            backgroundColor: Theme.of(context).colorScheme.surface,
            inputBackgroundColor:
                Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ),
          messages: messages,
          onSendPressed: (types.PartialText message) {
            _sendMessage(message, imageURL: '');
          },
          user: types.User(
            id: authAccount ?? '',
            firstName: myNickname,
            imageUrl: myImg,
          ),
          onAttachmentPressed: () {
            _showOptions(context);
          },
          customMessageBuilder: _buildCustomMessage,
        );
      },
    );
  }
}
