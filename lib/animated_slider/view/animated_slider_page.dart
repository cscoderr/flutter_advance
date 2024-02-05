import 'package:animation_playground/animated_slider/animated_slider.dart';
import 'package:flutter/material.dart';

class AnimatedSliderPage extends StatefulWidget {
  const AnimatedSliderPage({super.key});
  static PageRoute route() =>
      MaterialPageRoute(builder: (_) => const AnimatedSliderPage());

  @override
  State<AnimatedSliderPage> createState() => _AnimatedSliderPageState();
}

class _AnimatedSliderPageState extends State<AnimatedSliderPage> {
  double sliderValue = 100;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SliderTextWidget(
              text: sliderValue.toInt().toString(),
            ),
            const SizedBox(height: 30),
            Slider.adaptive(
              value: sliderValue,
              max: 4500,
              onChanged: (value) {
                setState(() {
                  sliderValue = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
