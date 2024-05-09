import 'package:flutter/material.dart';
import '../widgets/lost_things_list.dart';
import '../models/lost_thing.dart';

class FindedThingScreen extends StatefulWidget {
  const FindedThingScreen({super.key, required this.searchedThingName});
  final String searchedThingName;

  @override
  State<FindedThingScreen> createState() => _FindedThingScreenState();
}

class _FindedThingScreenState extends State<FindedThingScreen> {
  static List<LostThing> registedFindedThings = [
    LostThing(
      lostThingName: 'iPhone 11',
      content: '我找到了一台iPhone 11，請聯絡我。',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f5/IPhone_15_Pro_Vector.svg/800px-IPhone_15_Pro_Vector.svg.png',
      date: DateTime.now(),
      location: '共同教室2樓',
      postUser: 'Box159',
    ),
    LostThing(
      lostThingName: 'MacBook Air',
      content: '我找到了一台MacBook Air，請聯絡我。',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b6/MacBook_Pro_15_inch_%282017%29_Touch_Bar.jpg/1920px-MacBook_Pro_15_inch_%282017%29_Touch_Bar.jpg',
      date: DateTime.now(),
      location: '共同教室1樓',
      postUser: 'Chengen Li',
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
        return item.lostThingName.contains(widget.searchedThingName);
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
