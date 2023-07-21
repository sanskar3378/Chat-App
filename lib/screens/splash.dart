import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: brightness == Brightness.dark
            ? AppBarTheme.of(context).backgroundColor
            : Theme.of(context).colorScheme.primary,
        title: Text('WhatsApp clone',
            style: TextStyle(
              color: brightness == Brightness.dark
                  ? ThemeData.dark().colorScheme.onSurface
                  : Theme.of(context).colorScheme.onPrimary,
            )),
      ),
      body: const Center(
        child: Text('Loading...'),
      ),
    );
  }
}
