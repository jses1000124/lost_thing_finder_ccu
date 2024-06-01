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
    _loadUserPrefs().then((_) {
      _changeReadStatus();
    });
  }

  Future<void> _loadUserPrefs() async {
    final prefs = await _prefs;
    setState(() {
      authAccount = prefs.getString('email');
      myNickname = prefs.getString('nickname');
      myImg = prefs.getString('avatarid');
    });
  }

  void _changeReadStatus() {
    FirebaseFirestore.instance
        .collection('chat')
        .doc(widget.chatID)
        .update({'readStatus.${authAccount?.replaceAll('.', '_')}': true});

    FirebaseFirestore.instance
        .collection('chat')
        .doc(widget.chatID)
        .collection('message')
        .where('userEmail', isNotEqualTo: authAccount)
        .get()
        .then((value) {
      for (DocumentSnapshot doc in value.docs) {
        doc.reference.update({'isRead': true});
      }
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
      'readStatus.${widget.chatUserEmail.replaceAll('.', '_')}': false,
      'readStatus.${authAccount!.replaceAll('.', '_')}': true
    });

    sendNotification(widget.chatUserEmail, myNickname!,
        imageURL.isNotEmpty ? '📷 圖片' : message.text);
  }

  List<types.Message> _mapFirestoreDataToChatMessages(
      List<DocumentSnapshot> chatDocs) {
    return chatDocs.map((doc) {
      final chatMessage = doc.data() as Map<String, dynamic>;
      final user = types.User(id: chatMessage['userEmail']);

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
        );
      } else {
        return types.TextMessage(
          previewData: chatMessage['previewData'] != null
              ? types.PreviewData(
                  description: chatMessage['previewData']['description'],
                  image: chatMessage['previewData']['image']['height'] != null
                      ? types.PreviewDataImage(
                          height: chatMessage['previewData']['image']['height'],
                          url: chatMessage['previewData']['image']['url'],
                          width: chatMessage['previewData']['image']['width'],
                        )
                      : null,
                  link: chatMessage['previewData']['link'],
                  title: chatMessage['previewData']['title'],
                )
              : null,
          repliedMessage: types.TextMessage(
              author: user,
              id: chatMessage['repliedMessage'] ?? '',
              text: 'user replied message'),
          status: chatMessage['isRead']
              ? types.Status.seen
              : types.Status.delivered,
          author: user,
          createdAt:
              (chatMessage['createdAt'] as Timestamp).millisecondsSinceEpoch,
          id: doc.id,
          text: chatMessage['text'] ?? '',
          metadata: {
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
      bool isMe = message.author.id == authAccount;
      Color color = isMe ? Colors.white : Colors.black;

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
              if (post.imageUrl != '')
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(post.imageUrl),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              SizedBox(width: 10),
              Expanded(
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.lostThingName,
                        maxLines: 3,
                        style: TextStyle(fontSize: 20, color: color),
                      ),
                      Divider(color: color),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: color),
                          SizedBox(width: 5),
                          Text(
                            post.location.length > 7
                                ? post.location.substring(0, 7) + '...'
                                : post.location,
                            style: TextStyle(fontSize: 16, color: color),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.date_range, color: color),
                          SizedBox(width: 5),
                          Text(
                            post.formattedDate,
                            style: TextStyle(fontSize: 16, color: color),
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

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    FirebaseFirestore.instance
        .collection('chat')
        .doc(widget.chatID)
        .collection('message')
        .doc(message.id)
        .update({
      'previewData': {
        'description': previewData.description,
        'image': {
          'height': previewData.image?.height,
          'url': previewData.image?.url,
          'width': previewData.image?.width,
        },
        'link': previewData.link,
        'title': previewData.title,
      },
    });
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
            inputTextColor:
                Theme.of(context).colorScheme.brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
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
          onPreviewDataFetched: _handlePreviewDataFetched,
        );
      },
    );
  }
}
