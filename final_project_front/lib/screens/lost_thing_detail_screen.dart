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
        title: Text(
          lostThings.lostThingName,
          style: const TextStyle(fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 5,
                child: InkWell(
                  onTap: () {
                    // createNewChatRoom(lostThings.postUser);
                    // NavigationBar().navigateToChatScreen(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lostThings.location,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                lostThings.postUser,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        CircleAvatar(
                          backgroundImage: NetworkImage(lostThings
                              .headShotUrl), // Consider adding a user image property to the model
                          radius: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                lostThings.content,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Center(
                child: ClipRRect(
                  clipBehavior: Clip.hardEdge,
                  // Added ClipRRect to ensure the image does not overflow
                  borderRadius: BorderRadius.circular(8.0),
                  child: FadeInImage(
                    placeholder: MemoryImage(kTransparentImage),
                    image: NetworkImage(lostThings.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
