import 'package:cloud_firestore/cloud_firestore.dart';

class CreateNewChatRoom {
  Future<String> createNewChatRoom(
      String postUserEmail, String authEmail) async {
    // Create a new chat room
    DocumentReference roomRef =
        await FirebaseFirestore.instance.collection('chat').add({
      'lastUpdated': Timestamp.now(),
      'lastMessage': '',
      'member': [postUserEmail, authEmail],
    });
    return roomRef.id;
  }
}
