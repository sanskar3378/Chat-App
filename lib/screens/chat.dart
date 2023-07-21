import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../widgets/chat_messages.dart';
import '../widgets/new_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void setupPushNotifications() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    // final token = await FirebaseMessaging.instance.getToken();
    // print(token);
    fcm.subscribeToTopic('chat');
  }

  @override
  void initState() {
    super.initState();

    setupPushNotifications();
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: brightness == Brightness.dark
              ? AppBarTheme.of(context).backgroundColor
              : Theme.of(context).colorScheme.primary,
          title: Text(
            'WhatsApp clone',
            style: TextStyle(
              color: brightness == Brightness.dark
                  ? ThemeData.dark().colorScheme.onSurface
                  : Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                          title: const Text('Logging out'),
                          content: const Text('Do you really want to log out?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                              },
                              child: Text(
                                'No',
                                style: TextStyle(
                                  color: brightness == Brightness.dark
                                      ? ThemeData.dark()
                                          .colorScheme
                                          .onBackground
                                      : Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                FirebaseAuth.instance.signOut();
                                Navigator.pop(ctx);
                              },
                              child: Text(
                                'Yes',
                                style: TextStyle(
                                  color: brightness == Brightness.dark
                                      ? ThemeData.dark()
                                          .colorScheme
                                          .onBackground
                                      : Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ));
              },
              icon: Icon(
                Icons.exit_to_app,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            )
          ],
        ),
        body: const Column(
          children: [
            Expanded(
              child: Chatmessages(),
            ),
            NewMessage(),
          ],
        ));
  }
}
