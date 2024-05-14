import 'package:flutter/material.dart';
import '../widgets/lost_things_list.dart';
import '../models/lost_thing.dart';

class LostThingScreen extends StatefulWidget {
  final String searchedThingName; // Add this

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
    setState(() {
      if (widget.searchedThingName.isEmpty) {
        filteredLostThings = registedlostThings; // Show all if no search
      } else {
        filteredLostThings = registedlostThings.where((item) {
          return item.lostThingName
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

  final List<LostThing> registedlostThings = [
    LostThing(
      lostThingName: 'iPhone 12',
      content: 'HI, I lost my iPhone 12, please help me to find it.',
      imageUrl:
          'https://store.storeimages.cdn-apple.com/8756/as-images.apple.com/is/iphone-card-40-iphone15prohero-202309?wid=680&hei=528&fmt=p-jpg&qlt=95&.v=1693086290312',
      date: DateTime.now(),
      location: 'Taipei City',
      postUser: 'box159',
      postUserEmail: 'aa94022728@gmail.com',
      headShotUrl: 'https://i.pravatar.cc/150?u=a042581f4e29026704d',
    ),
    LostThing(
      lostThingName: 'MacBook Pro',
      content: 'HI, I lost my MacBook Pro, please help me to find it.',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b6/MacBook_Pro_15_inch_%282017%29_Touch_Bar.jpg/1920px-MacBook_Pro_15_inch_%282017%29_Touch_Bar.jpg',
      date: DateTime.now(),
      location: 'Taipei City',
      postUser: '小乖',
      postUserEmail: 'jses0922737039@gmail.com',
      headShotUrl: 'https://i.pravatar.cc/150?u=a042581f4e29026704d',
    ),
  ]; // Your items

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: LostThingsList(lostThings: filteredLostThings),
        )
      ],
    );
  }
}
