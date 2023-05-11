import 'package:flutter/material.dart';

// Firebase SDK imports
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Widget imports
import 'package:chat_app/widgets/message_bubble.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .orderBy(
            'createdAt',
            descending: true,
          )
          .snapshots(),
      builder: (context, chatsSnapshot) {
        if (chatsSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!chatsSnapshot.hasData || chatsSnapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No messages found."),
          );
        }

        final loadedMessages = chatsSnapshot.data!.docs;

        return ListView.builder(
          itemCount: loadedMessages.length,
          padding: const EdgeInsets.only(bottom: 32, left: 8, right: 8),
          reverse: true,
          itemBuilder: (context, index) {
            final chatMessage = loadedMessages[index].data();
            final nextChatMessage = index + 1 < loadedMessages.length
                ? loadedMessages[index + 1].data()
                : null;
            final currentMessageUserId = chatMessage['userId'];
            final nextMessageUserId =
                nextChatMessage != null ? nextChatMessage['userId'] : null;
            final nextUserIsSame = nextMessageUserId == currentMessageUserId;

            if (nextUserIsSame) {
              return MessageBubble.next(
                message: chatMessage['text'],
                isMe: authenticatedUser.uid == currentMessageUserId,
              );
            } else {
              return MessageBubble.first(
                userImage: chatMessage['userImage'],
                username: chatMessage['username'],
                message: chatMessage['text'],
                isMe: authenticatedUser.uid == currentMessageUserId,
              );
            }
          },
        );
      },
    );
  }
}
