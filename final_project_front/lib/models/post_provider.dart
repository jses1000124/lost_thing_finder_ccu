import 'dart:convert';
import 'dart:async'; 
import 'package:final_project/models/lost_thing_and_Url.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:http/http.dart' as http;

class PostProvider with ChangeNotifier {
  List<LostThing> posts = [];
  late io.Socket socket;
  bool isLoading = true; 

  PostProvider() {
    connectAndListen();
  }

  void connectAndListen() {
    socket = io.io(basedApiUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });
    socket.connect();

    socket.onConnect((_) {
      print('Connected to WebSocket Server');
      socket.emit('get_posts', 'Client is connected!');
    });

    socket.on('posts_data', (data) {
      print('Received posts data');
      try {
        posts = (data as List).map((item) => LostThing.fromMap(item)).toList();
        posts = posts.reversed.toList(); 
        isLoading = false; 

        // Mask author emails before printing
        // var maskedData = posts.map((post) {
        //   var postMap = post.toMap();
        //   postMap['author_email'] = '****@****.***'; // Mask email
        //   return postMap;
        // }).toList();
        // debugPrint('Filtered posts data: $maskedData');
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
      isLoading = false; 
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
          headers: {
            'Content-Type': 'application/json'
          }).timeout(const Duration(seconds: 10)); 

      if (response.statusCode == 200) {
        posts.removeWhere((post) => post.id == postId);
        notifyListeners();
        return 200;
      } else {
        return response.statusCode;
      }
    } on TimeoutException catch (_) {
      print('Error: Request timed out');
      return 408; 
    } catch (e) {
      print('Error deleting post: $e');
      return 8787;
    }
  }

  Future<int> updatePost(LostThing updatedPost, String token) async {
    final Uri apiUrl = Uri.parse('$basedApiUrl/update_post');
    final Map<String, Object?> requestBody = {
      'token': token,
      'id': updatedPost.id.toString(),
      'title': updatedPost.lostThingName,
      'context': updatedPost.content,
      'location': updatedPost.location,
      'date': updatedPost.date.toIso8601String(),
      'my_losting': updatedPost.mylosting,
      'latitude': updatedPost.latitude.toString(),
      'longitude': updatedPost.longitude.toString(),
      'image': updatedPost.imageUrl,
    };

    try {
      final response = await http.post(apiUrl,
          body: jsonEncode(requestBody),
          headers: {
            'Content-Type': 'application/json'
          }).timeout(const Duration(seconds: 10)); 

      if (response.statusCode == 200) {
        final index = posts.indexWhere((post) => post.id == updatedPost.id);
        if (index != -1) {
          posts[index] = updatedPost;
          notifyListeners();
        }
        return 200;
      } else {
        return response.statusCode;
      }
    } on TimeoutException catch (_) {
      print('Error: Request timed out');
      return 408; 
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
