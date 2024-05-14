import 'package:flutter/material.dart';
import '../widgets/lost_things_list.dart';
import '../models/lost_thing.dart';

class FindedThingScreen extends StatefulWidget {
  final String searchedThingName;
  const FindedThingScreen({super.key, this.searchedThingName = ''});

  @override
  State<FindedThingScreen> createState() => _FindedThingScreenState();
}

class _FindedThingScreenState extends State<FindedThingScreen> {
  static List<LostThing> registedFindedThings = [
    LostThing(
      lostThingName: 'iPhone 11',
      content: '我找到了一台iPhone 11，請聯絡我。',
      postUserEmail: 'aa94022728@gmail.com',
      imageUrl:
          'https://store.storeimages.cdn-apple.com/8756/as-images.apple.com/is/iphone-card-40-iphone15prohero-202309?wid=680&hei=528&fmt=p-jpg&qlt=95&.v=1693086290312',
      date: DateTime.now(),
      location: '共同教室2樓',
      postUser: 'Box159',
      headShotUrl: 'https://i.pravatar.cc/150?u=a042581f4e29026704d',
    ),
    LostThing(
      lostThingName: 'MacBook Air',
      content: '我找到了一台MacBook Air，請聯絡我。',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b6/MacBook_Pro_15_inch_%282017%29_Touch_Bar.jpg/1920px-MacBook_Pro_15_inch_%282017%29_Touch_Bar.jpg',
      date: DateTime.now(),
      location: '共同教室1樓',
      postUserEmail: 'han@csie.io',
      postUser: 'Han',
      headShotUrl: 'https://i.pravatar.cc/150?u=a042581f4e29026704d',
    ),
  ];

  List<LostThing> filteredFindedThings = [];

  @override
  void initState() {
    super.initState();
    // Initially filter items based on initial search value
    filterItems();
  }

  void filterItems() {
    setState(() {
      filteredFindedThings = registedFindedThings.where((item) {
        return item.lostThingName
            .toLowerCase()
            .contains(widget.searchedThingName.toLowerCase());
      }).toList();
    });
  }

  @override
  void didUpdateWidget(covariant FindedThingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refilter items if the search query changes
    if (widget.searchedThingName != oldWidget.searchedThingName) {
      filterItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: LostThingsList(
              lostThings: filteredFindedThings.isEmpty
                  ? registedFindedThings
                  : filteredFindedThings),
        )
      ],
    );
  }
}
