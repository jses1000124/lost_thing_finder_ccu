import 'package:final_project/data/create_new_room.dart';
import 'package:final_project/screens/chat_screen.dart';
import 'package:final_project/widgets/show_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:final_project/models/lost_thing.dart';

class LostThingDetailScreen extends StatefulWidget {
  final LostThing lostThings;
  const LostThingDetailScreen({super.key, required this.lostThings});

  @override
  State<LostThingDetailScreen> createState() => _LostThing();
}

class _LostThing extends State<LostThingDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LostThing lostThings = widget.lostThings;
    String authEmail = '';

    _getPrefs().then((prefs) {
      authEmail = prefs.getString('email')!;
    });

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
              const SizedBox(height: 20),
              Text(
                lostThings.content,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Center(
                child: lostThings.imageUrl != ''
                    ? ClipRRect(
                        clipBehavior: Clip.hardEdge,
                        // Added ClipRRect to ensure the image does not overflow
                        borderRadius: BorderRadius.circular(8.0),
                        child: FadeInImage(
                          placeholder: MemoryImage(kTransparentImage),
                          image: NetworkImage(lostThings.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      )
                    : const SizedBox(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _animation,
        child: FloatingActionButton(
          onPressed: () async {
            if (authEmail == lostThings.postUserEmail) {
              ShowAlertDialog()
                  .showAlertDialog('無法與自己聊天', '無法與自己的帳號進行聊天', context);
              return;
            }
            await CreateNewChatRoom()
                .createNewChatRoom(lostThings.postUserEmail, authEmail)
                .then(
              (chatID) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (ctx) => ChatScreen(
                      chatID: chatID,
                      chatUserEmail: lostThings.postUserEmail,
                    ),
                  ),
                );
              },
            );
          },
          backgroundColor: Theme.of(context).focusColor,
          child: const Icon(Icons.message),
        ),
      ),
    );
  }
}
