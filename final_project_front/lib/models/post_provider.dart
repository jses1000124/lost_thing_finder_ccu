import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../models/lost_thing.dart';

class PostProvider with ChangeNotifier {
  List<LostThing> posts = [];
  late io.Socket socket;
  VoidCallback? onPostsLoaded;

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

    socket.onConnectError((data) {
      print('Connection Error: $data');
    });

    socket.onConnectTimeout((data) {
      print('Connection Timeout: $data');
    });

    socket.onError((data) {
      print('Error: $data');
    });

    socket.onDisconnect((_) {
      print('Disconnected from WebSocket Server');
    });

    socket.on('posts_data', (data) {
      print('Received posts data: $data');
      try {
        posts = (data as List).map((item) => LostThing.fromMap(item)).toList();
        notifyListeners();
        if (onPostsLoaded != null) {
          onPostsLoaded!(); // Call the callback when posts data is loaded
        }
      } catch (e) {
        print('Error parsing posts data: $e');
      }
    });
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }
}
