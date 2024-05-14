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
  List<LostThing> filteredLostThings = [];

  @override
  void initState() {
    super.initState();
    _filterItems();
  }

  void _filterItems() {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    setState(() {
      if (widget.searchedThingName.isEmpty) {
        filteredLostThings = postProvider.posts.where((item) {
          return item.mylosting == 0;
        }).toList(); // Show all if no search
      } else {
        filteredLostThings = postProvider.posts.where((item) {
          return item.mylosting == 0 &&
              item.lostThingName
                  .toLowerCase()
                  .contains(widget.searchedThingName.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  void didUpdateWidget(covariant LostThingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchedThingName != oldWidget.searchedThingName) {
      _filterItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PostProvider>(builder: (context, postProvider, child) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: LostThingsList(lostThings: filteredLostThings),
          )
        ],
      );
    });
  }
}
