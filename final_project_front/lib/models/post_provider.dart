import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'lost_thing_and_Url.dart';

class PostProvider with ChangeNotifier {
  List<LostThing> posts = [];
  late io.Socket socket;
  bool isLoading = true; // Add this to track loading state

  PostProvider() {
    connectAndListen();
  }

  void connectAndListen() {
    socket = io.io('http://140.123.101.199:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });
    socket.connect();

    socket.onConnect((_) {
      print('Connected to WebSocket Server');
      socket.emit('get_posts', 'Client is connected!');
    });

    socket.on('posts_data', (data) {
      print('Received posts data: $data');
      try {
        posts = (data as List).map((item) => LostThing.fromMap(item)).toList();
        isLoading = false; // Update loading state
        notifyListeners();
      } catch (e) {
        print('Error parsing posts data: $e');
      }
    });

    socket.onDisconnect((_) {
      print('Disconnected from WebSocket Server');
    });

    socket.onError((data) {
      print('Error: $data');
      isLoading = false; // Ensure to update on error too
      notifyListeners();
    });
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }
}
