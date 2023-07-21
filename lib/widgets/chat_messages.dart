import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/message_bubble.dart';

class Chatmessages extends StatelessWidget {
  const Chatmessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy(
            'createdAt',
            descending: true,
          )
          .snapshots(),
      builder: (ctx, chatSnapshots) {
        if (chatSnapshots.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
          return const Center(
            child: Text('No messages found'),
          );
        }

        if (chatSnapshots.hasError) {
          return const Center(
            child: Text('Error'),
          );
        }
        final loadedmessages = chatSnapshots.data!.docs;
        return ListView.builder(
            padding: const EdgeInsets.only(
              bottom: 40,
              left: 13,
              right: 13,
            ),
            reverse: true,
            itemCount: loadedmessages.length,
            itemBuilder: (ctx, index) {
              final chatMessage = loadedmessages[index].data();
              final nextChatMessage = index + 1 < loadedmessages.length
                  ? loadedmessages[index + 1].data()
                  : null;
              final currentMessageUserid = chatMessage['userId'];

              final nextMessageUserid =
                  nextChatMessage != null ? nextChatMessage['userId'] : null;
              final nextUserIsSame = nextMessageUserid == currentMessageUserid;

              if (nextUserIsSame) {
                return MessageBubble.next(
                  message: chatMessage['text'],
                  isMe: authenticatedUser.uid == currentMessageUserid,
                );
              } else {
                print('answer');
                print(chatMessage['username']);
                return MessageBubble.first(
                  userImage: chatMessage['userImage'],
                  username: chatMessage['username'],
                  message: chatMessage['text'],
                  isMe: authenticatedUser.uid == currentMessageUserid,
                );
              }
            });
      },
    );
  }
}
