import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:final_project/models/lost_thing.dart';

class LostThingDetailScreen extends StatelessWidget {
  const LostThingDetailScreen({super.key, required this.lostThings});
  final LostThing lostThings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lost Thing Detail',
            style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(lostThings.lostThingName,
                  style: const TextStyle(color: Colors.white, fontSize: 30)),
              const SizedBox(height: 20),
              Text(lostThings.location,
                  style: const TextStyle(color: Colors.white, fontSize: 20)),
              const SizedBox(height: 20),
              Text(lostThings.postUser,
                  style: const TextStyle(color: Colors.white, fontSize: 20)),
              const SizedBox(height: 20),
              Text(lostThings.content,
                  style: const TextStyle(color: Colors.white, fontSize: 20)),
              const SizedBox(height: 20),
              SizedBox(
                // color: Colors.black12,
                child: FadeInImage(
                  placeholder: MemoryImage(kTransparentImage),
                  image: NetworkImage(lostThings.imageUrl),
                  height: 300,
                  width: 300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
