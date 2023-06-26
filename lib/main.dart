import 'package:animation_playground/water_wave_animation/water_wave_animation_page.dart';
import 'package:flutter/material.dart';

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
      theme: ThemeData.dark(),
      home: const WaterWaveAnimationPage(),
    );
  }
}
