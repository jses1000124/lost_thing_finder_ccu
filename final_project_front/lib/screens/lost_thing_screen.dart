import 'package:flutter/material.dart';
import '../widgets/lost_things_list.dart';
import '../models/lost_thing.dart';

class LostThingScreen extends StatefulWidget {
  const LostThingScreen({super.key});

  @override
  State<LostThingScreen> createState() => _LostThingScreenState();
}

class _LostThingScreenState extends State<LostThingScreen> {
  final List<LostThing> _registedlostThings = [
    LostThing(
      lostThingName: 'iPhone 12',
      content: 'HI, I lost my iPhone 12, please help me to find it.',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f5/IPhone_15_Pro_Vector.svg/800px-IPhone_15_Pro_Vector.svg.png',
      date: DateTime.now(),
      location: 'Taipei City',
      postUser: 'John Doe',
    ),
    LostThing(
      lostThingName: 'MacBook Pro',
      content: 'HI, I lost my MacBook Pro, please help me to find it.',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b6/MacBook_Pro_15_inch_%282017%29_Touch_Bar.jpg/1920px-MacBook_Pro_15_inch_%282017%29_Touch_Bar.jpg',
      date: DateTime.now(),
      location: 'Taipei City',
      postUser: 'Jane Doe',
    ),
    LostThing(
      lostThingName: 'iPhone 12',
      content: 'HI, I lost my iPhone 12, please help me to find it.',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f5/IPhone_15_Pro_Vector.svg/800px-IPhone_15_Pro_Vector.svg.png',
      date: DateTime.now(),
      location: 'Taipei City',
      postUser: 'John Doe',
    ),
    LostThing(
      lostThingName: 'MacBook Pro',
      content: 'HI, I lost my MacBook Pro, please help me to find it.',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b6/MacBook_Pro_15_inch_%282017%29_Touch_Bar.jpg/1920px-MacBook_Pro_15_inch_%282017%29_Touch_Bar.jpg',
      date: DateTime.now(),
      location: 'Taipei City',
      postUser: 'Jane Doe',
    ),
    LostThing(
      lostThingName: 'iPhone 12',
      content: 'HI, I lost my iPhone 12, please help me to find it.',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f5/IPhone_15_Pro_Vector.svg/800px-IPhone_15_Pro_Vector.svg.png',
      date: DateTime.now(),
      location: 'Taipei City',
      postUser: 'John Doe',
    ),
    LostThing(
      lostThingName: 'MacBook Pro',
      content: 'HI, I lost my MacBook Pro, please help me to find it.',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b6/MacBook_Pro_15_inch_%282017%29_Touch_Bar.jpg/1920px-MacBook_Pro_15_inch_%282017%29_Touch_Bar.jpg',
      date: DateTime.now(),
      location: 'Taipei City',
      postUser: 'Jane Doe',
    ),
    LostThing(
      lostThingName: 'iPhone 12',
      content: 'HI, I lost my iPhone 12, please help me to find it.',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f5/IPhone_15_Pro_Vector.svg/800px-IPhone_15_Pro_Vector.svg.png',
      date: DateTime.now(),
      location: 'Taipei City',
      postUser: 'John Doe',
    ),
    LostThing(
      lostThingName: 'MacBook Pro',
      content: 'HI, I lost my MacBook Pro, please help me to find it.',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b6/MacBook_Pro_15_inch_%282017%29_Touch_Bar.jpg/1920px-MacBook_Pro_15_inch_%282017%29_Touch_Bar.jpg',
      date: DateTime.now(),
      location: 'Taipei City',
      postUser: 'Jane Doe',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: LostThingsList(lostThings: _registedlostThings),
        )
      ],
    );
  }
}
