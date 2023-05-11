import 'package:flutter/material.dart';

// Firebase SDK imports
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitMessage() async {
    FocusScope.of(context).unfocus();
    final enteredMessage = _messageController.text.trim();

    if (enteredMessage.isEmpty) return;

    // Send to Firebase
    final user = FirebaseAuth.instance.currentUser;

    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    FirebaseFirestore.instance.collection('chats').add({
      'text': enteredMessage,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'username': userData.data()!['username'],
      'userImage': userData.data()!['image_url'],
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 2, bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: const InputDecoration(labelText: 'Send a message...'),
            ),
          ),
          IconButton(
            onPressed: _submitMessage,
            color: Theme.of(context).colorScheme.primary,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
