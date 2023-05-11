import 'package:flutter/material.dart';

// Firebase SDK imports
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Screen imports
import 'package:chat_app/widgets/chat_messages.dart';
import 'package:chat_app/widgets/new_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Future<void> setupPushNotifications() async {
    final firebaseMessaging = FirebaseMessaging.instance;

    await firebaseMessaging.requestPermission();

    firebaseMessaging.subscribeToTopic('chat');
  }

  @override
  void initState() {
    super.initState();

    setupPushNotifications();
  }

  @override
  Widget build(BuildContext context) {
    void logout() {
      FirebaseAuth.instance.signOut();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Chat"),
        actions: [
          IconButton(
            onPressed: logout,
            icon: Icon(
              Icons.exit_to_app,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: const [
            Expanded(
              child: ChatMessages(),
            ),
            NewMessage(),
          ],
        ),
      ),
    );
  }
}
