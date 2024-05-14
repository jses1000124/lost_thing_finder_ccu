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
  List<LostThing> filteredFindedThings = [];

  @override
  void initState() {
    super.initState();
    filterItems();
  }

  void filterItems() {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    setState(() {
      if (widget.searchedThingName.isEmpty) {
        filteredFindedThings = postProvider.posts.where((item) {
          return item.mylosting == 1;
        }).toList();
      } else {
        filteredFindedThings = postProvider.posts.where((item) {
          return item.mylosting == 1 &&
              item.lostThingName
                  .toLowerCase()
                  .contains(widget.searchedThingName.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  void didUpdateWidget(covariant FindedThingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchedThingName != oldWidget.searchedThingName) {
      filterItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PostProvider>(builder: (context, postProvider, child) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: LostThingsList(lostThings: filteredFindedThings),
          )
        ],
      );
    });
  }
}
