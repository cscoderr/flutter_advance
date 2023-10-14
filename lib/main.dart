import 'package:flutter/material.dart';

import 'rainbow_sticks_rotation_animation/rainbow_sticks.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Advance',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const RainbowSticksPage(),
    );
  }
}
