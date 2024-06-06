import 'package:flutter/material.dart';
import '../widgets/lost_things_list.dart';
import '../models/lost_thing_and_Url.dart';
import 'package:provider/provider.dart';
import '../models/post_provider.dart';

class LostThingScreen extends StatefulWidget {
  final String searchedThingName;

  const LostThingScreen({super.key, this.searchedThingName = ''});

  @override
  State<LostThingScreen> createState() => _LostThingScreenState();
}

class _LostThingScreenState extends State<LostThingScreen> {
  Future<void> _refreshPosts(BuildContext context) async {
    await Provider.of<PostProvider>(context, listen: false).fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    
    
    
    return Consumer<PostProvider>(builder: (context, postProvider, child) {
      List<LostThing> filteredLostThings = [];
      if (widget.searchedThingName.isEmpty) {
        filteredLostThings =
            postProvider.posts.where((item) => item.mylosting == 0).toList();
      } else {
        filteredLostThings = postProvider.posts.where((item) {
          final searchLower = widget.searchedThingName.toLowerCase();
          return item.mylosting == 0 &&
              (item.lostThingName.toLowerCase().contains(searchLower) ||
                  item.location.toLowerCase().contains(searchLower));
        }).toList();
      }
      return RefreshIndicator(
        onRefresh: () => _refreshPosts(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: LostThingsList(lostThings: filteredLostThings),
            )
          ],
        ),
      );
    });
  }
}
