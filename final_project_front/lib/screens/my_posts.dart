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
  List<LostThing> filteredLostThings = [];
  String? email;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    email = prefs.getString('email');
    if (email != null) {
      _filterItems();
    } else {
      // Handle the case when email is not set in preferences
      setState(() {
        filteredLostThings = [];
      });
    }
  }

  void _filterItems() {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    setState(() {
      filteredLostThings = postProvider.posts.where((item) {
        return item.postUserEmail
            .contains(email!); // email is now guaranteed to be non-null here
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PostProvider>(builder: (context, postProvider, child) {
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
