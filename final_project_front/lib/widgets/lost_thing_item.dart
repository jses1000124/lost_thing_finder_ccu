import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:final_project/models/lost_thing.dart';

class LostThingItem extends StatelessWidget {
  const LostThingItem(this.lostThing, {super.key});

  final LostThing lostThing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        child: InkWell(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Colors.black12,
                child: FadeInImage(
                  placeholder: MemoryImage(kTransparentImage),
                  image: NetworkImage(lostThing.imageUrl),
                  height: 80,
                  width: 80,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      lostThing.lostThingName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      'Location: ${lostThing.location}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      'Date: ${lostThing.formattedDate}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
