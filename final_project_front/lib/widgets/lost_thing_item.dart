import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:final_project/models/lost_thing.dart';
import 'package:final_project/screens/lost_thing_detail_screen.dart';

class LostThingItem extends StatelessWidget {
  const LostThingItem(this.lostThing, {super.key});

  final LostThing lostThing;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        child: InkWell(
          splashColor: const Color.fromARGB(0, 255, 255, 255),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => LostThingDetailScreen(
                      lostThings: lostThing,
                    )));
          },
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
                      '位置: ${lostThing.location}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      '日期: ${lostThing.formattedDate}',
                      style: const TextStyle(fontSize: 16),
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
