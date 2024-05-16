import 'package:final_project/models/post_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/lost_things_list.dart';
import '../models/lost_thing_and_Url.dart';

class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({super.key});
  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  String? email;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PostProvider>(builder: (context, postProvider, child) {
      if (email == null) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('我的貼文'),
          ),
          body: const Center(child: CircularProgressIndicator()),
        );
      }

      List<LostThing> filteredLostThings = postProvider.posts.where((item) {
        return item.postUserEmail.contains(email!);
      }).toList();

      return Scaffold(
        appBar: AppBar(
          title: const Text('我的貼文'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: filteredLostThings.isEmpty
                  ? const Center(child: Text('你還沒發過任何文章喔~'))
                  : LostThingsList(lostThings: filteredLostThings),
            ),
          ],
        ),
      );
    });
  }
}
