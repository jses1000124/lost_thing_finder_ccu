import 'package:cloud_firestore/cloud_firestore.dart';

class CreateNewChatRoom {
  Future<String> createNewChatRoom(
      String postUserEmail, String authEmail) async {
    // Create a new chat room
    if (postUserEmail == authEmail) return '';

    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('chat')
        .where('member', isEqualTo: [postUserEmail, authEmail]).get();
    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs[0].id;
    }
    DocumentReference roomRef =
        await FirebaseFirestore.instance.collection('chat').add({
      'lastUpdated': Timestamp.now(),
      'lastMessage': '',
      'member': [postUserEmail, authEmail],
    });
    return roomRef.id;
  }
}
