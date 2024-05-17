import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'lost_thing_and_Url.dart';
import 'package:http/http.dart' as http;

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

  Future<void> fetchPosts() async {
    socket.emit('get_posts', 'Client requested posts!');
  }

  Future<int> deletePost(Object? postId, Object? token) async {
    final Uri apiUrl = Uri.parse('$basedApiUrl/delete_post');
    final Map<String, Object?> requestBody = {
      'token': token,
      'id': postId,
    };

    try {
      final response = await http.post(apiUrl,
          body: jsonEncode(requestBody),
          headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        posts.removeWhere((post) => post.id == postId);
        notifyListeners();
        return 200;
      } else {
        return response.statusCode;
      }
    } catch (e) {
      print('Error deleting post: $e');
      return 8787;
    }
  }

  Future<int> updatePost(LostThing updatedPost, String token) async {
    final Uri apiUrl = Uri.parse('$basedApiUrl/update_post');
    final Map<String, Object?> requestBody = {
      'token': token,
      'post_id': updatedPost.id,
      'title': updatedPost.lostThingName,
      'context': updatedPost.content,
      'location': updatedPost.location,
      'date': updatedPost.date,
      'my_losting': updatedPost.mylosting,
    };

    try {
      final response = await http.post(apiUrl,
          body: jsonEncode(requestBody),
          headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        // Find the post and update its details
        final index = posts.indexWhere((post) => post.id == updatedPost.id);
        if (index != -1) {
          posts[index] = updatedPost;
          notifyListeners();
        }
        return 200;
      } else {
        return response.statusCode;
      }
    } catch (e) {
      print('Error updating post: $e');
      return 8787;
    }
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }
}
