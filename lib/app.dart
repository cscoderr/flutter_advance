import 'package:animation_playground/animated_card.dart';
import 'package:animation_playground/animated_lock.dart';
import 'package:animation_playground/animated_progress_bar.dart';
import 'package:animation_playground/blur_animation.dart';
import 'package:animation_playground/petal_menu.dart';
import 'package:animation_playground/phone_pattern.dart';
import 'package:animation_playground/rainbow_sticks_page.dart';
import 'package:animation_playground/water_wave_animation/water_wave_animation_page.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Advance Animations"),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          SolidButton(
            text: "Blur Animation",
            onPressed: () => Navigator.of(context).push(BlurAnimation.route()),
          ),
          const SizedBox(height: 20),
          SolidButton(
            text: "Petal Menu Animation",
            onPressed: () => Navigator.of(context).push(PetalMenu.route()),
          ),
          const SizedBox(height: 20),
          SolidButton(
            text: "Rainbow Stick Animation",
            onPressed: () =>
                Navigator.of(context).push(RainbowSticksPage.route()),
          ),
          const SizedBox(height: 20),
          SolidButton(
            text: "Animated Lock",
            onPressed: () => Navigator.of(context).push(AnimatedLock.route()),
          ),
          const SizedBox(height: 20),
          SolidButton(
            text: "Animated Progress Bar",
            onPressed: () =>
                Navigator.of(context).push(AnimatedProgressBar.route()),
          ),
          const SizedBox(height: 20),
          SolidButton(
            text: "Animated Card",
            onPressed: () =>
                Navigator.of(context).push(AnimatedCardPage.route()),
          ),
          const SizedBox(height: 20),
          SolidButton(
            text: "Phone Pattern",
            onPressed: () =>
                Navigator.of(context).push(PhonePatternPage.route()),
          ),
          const SizedBox(height: 20),
          SolidButton(
            text: "Water Wave Animation",
            onPressed: () =>
                Navigator.of(context).push(WaterWaveAnimationPage.route()),
          ),
        ],
      ),
    );
  }
}

class SolidButton extends StatelessWidget {
  const SolidButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
          fixedSize: Size(MediaQuery.sizeOf(context).width, 60)),
      child: Text(text),
    );
  }
}
