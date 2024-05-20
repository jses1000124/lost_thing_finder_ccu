import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/chatlist_screen.dart';

class ChatIconWithNotification extends StatefulWidget {
  const ChatIconWithNotification({super.key});
  @override
  State<ChatIconWithNotification> createState() =>
      _ChatIconWithNotificationState();
}

class _ChatIconWithNotificationState extends State<ChatIconWithNotification> {
  String? authaccount;

  @override
  void initState() {
    super.initState();
    _getPrefs().then((prefs) {
      setState(() {
        authaccount = prefs.getString('email');
      });
    });
  }

  Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    if (authaccount == null) {
      return IconButton(
        icon: const Icon(Icons.chat),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ChatListScreen(),
          ),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .where('member', arrayContains: authaccount)
          .snapshots(),
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) {
          return IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ChatListScreen(),
              ),
            ),
          );
        }

        int unreadCount = snapshot.data!.docs.where((doc) {
          final readStatus = doc['readStatus'] as Map<String, dynamic>;
          return !(readStatus[authaccount!.replaceAll('.', '_')] ?? true);
        }).length;

        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.chat),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ChatListScreen(),
                ),
              ),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Center(
                    child: Text(
                      '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
