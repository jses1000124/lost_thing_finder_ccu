import 'package:flutter/material.dart';
import '../widgets/lost_things_list.dart';
import '../models/lost_thing_and_Url.dart';
import '../models/post_provider.dart';
import 'package:provider/provider.dart';

class FindedThingScreen extends StatefulWidget {
  final String searchedThingName;

  const FindedThingScreen({super.key, this.searchedThingName = ''});

  @override
  State<FindedThingScreen> createState() => _FindedThingScreenState();
}

class _FindedThingScreenState extends State<FindedThingScreen> {
  Future<void> _refreshPosts(BuildContext context) async {
    await Provider.of<PostProvider>(context, listen: false).fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PostProvider>(
      builder: (context, postProvider, child) {
        List<LostThing> filteredFoundThings = [];
        if (widget.searchedThingName.isEmpty) {
          filteredFoundThings =
              postProvider.posts.where((item) => item.mylosting == 1).toList();
        } else {
          filteredFoundThings = postProvider.posts.where((item) {
            final searchLower = widget.searchedThingName.toLowerCase();
            return item.mylosting == 1 &&
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
                child: LostThingsList(lostThings: filteredFoundThings),
              )
            ],
          ),
        );
      },
    );
  }
}
