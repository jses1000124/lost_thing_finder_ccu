import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:final_project/models/lost_thing_and_Url.dart';

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
  late Future<String?> _authEmailFuture;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
    _authEmailFuture = _getAuthEmail();
  }

  Future<String?> _getAuthEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _authEmailFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          String authEmail = snapshot.data!;
          return _buildUI(context, authEmail);
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  Widget _buildUI(BuildContext context, String authEmail) {
    final LostThing lostThings = widget.lostThings;
    return Scaffold(
      appBar: AppBar(title: Text(lostThings.lostThingName)),
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
      floatingActionButton: authEmail == lostThings.postUserEmail
          ? null
          : ScaleTransition(
              scale: _animation,
              child: FloatingActionButton(
                onPressed: () => _handleMessageButtonPressed(
                    context, authEmail, lostThings.postUserEmail),
                backgroundColor: Theme.of(context).focusColor,
                child: const Icon(Icons.message),
              ),
            ),
    );
  }

  void _handleMessageButtonPressed(
      BuildContext context, String senderEmail, String recipientEmail) async {
    String? chatID = await CreateNewChatRoom()
        .createNewChatRoom(recipientEmail, senderEmail);
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (ctx) =>
          ChatScreen(chatID: chatID, chatUserEmail: recipientEmail),
    ));
  }
}
