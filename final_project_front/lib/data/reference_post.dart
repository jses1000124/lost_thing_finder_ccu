import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/models/lost_thing_and_Url.dart';

void referencePost(String chatID, String authEmail, LostThing post) async {
  DocumentReference chatroom =
      await FirebaseFirestore.instance.collection('chat').doc(chatID);
  DocumentSnapshot chatroomSnapshot = await chatroom.get();

  String? currentPostID =
      (chatroomSnapshot.data() as Map<String, dynamic>)['currentPostID'];
  String postID = post.id.toString();
  if (currentPostID == postID) return;

  chatroom.update({'currentPostID': postID});

  chatroom.collection('message').add({
    'userEmail': authEmail,
    'createdAt': Timestamp.now(),
    'postID': postID,
    'type': 'custom',
  });
}
