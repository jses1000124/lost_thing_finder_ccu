import 'package:cloud_firestore/cloud_firestore.dart';

Future<String> createNewChatRoom(String postUserEmail, String authEmail) async {
  // Create a new chat room
  if (postUserEmail == authEmail) return '';

  QuerySnapshot snapshot1 = await FirebaseFirestore.instance
      .collection('chat')
      .where('member', arrayContains: postUserEmail)
      .get();
  QuerySnapshot snapshot2 = await FirebaseFirestore.instance
      .collection('chat')
      .where('member', arrayContains: authEmail)
      .get();

  for (DocumentSnapshot doc in snapshot1.docs) {
    if (snapshot2.docs.any((doc2) => doc2.id == doc.id)) {
      return doc.id;
    }
  }

  DocumentReference roomRef =
      await FirebaseFirestore.instance.collection('chat').add({
    'lastUpdated': Timestamp.now(),
    'lastMessage': '',
    'member': [postUserEmail, authEmail],
    'readStatus': {
      postUserEmail.replaceAll('.', '_'): true,
      authEmail.replaceAll('.', '_'): true
    },
    'isLastMessageImage': false,
    'currentPostID': '',
  });
  return roomRef.id;
}
