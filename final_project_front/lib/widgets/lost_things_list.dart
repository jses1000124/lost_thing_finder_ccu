import 'package:flutter/material.dart';
import '../models/lost_thing_and_Url.dart';
import '../widgets/lost_thing_item.dart';

class LostThingsList extends StatelessWidget {
  const LostThingsList({super.key, required this.lostThings});
  final List<LostThing> lostThings;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: lostThings.length,
      itemBuilder: (ctx, index) => LostThingItem(lostThings[index]),
    );
  }
}
