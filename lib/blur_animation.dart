import 'dart:ui';

import 'package:flutter/material.dart';

class BlurAnimation extends StatefulWidget {
  const BlurAnimation({super.key});

  static PageRoute route() =>
      MaterialPageRoute(builder: (_) => const BlurAnimation());

  @override
  State<BlurAnimation> createState() => _BlurAnimationState();
}

class _BlurAnimationState extends State<BlurAnimation>
    with SingleTickerProviderStateMixin {
  final text = "FOCUS";
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.ease),
    );
  }

  @override
  Widget build(BuildContext context) {
    final words = text.split("");
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: words.asMap().entries.map((e) {
              final key = GlobalKey();
              return Listener(
                onPointerDown: (event) {
                  RenderBox box =
                      key.currentContext!.findRenderObject() as RenderBox;
                  Offset position = box.localToGlobal(Offset.zero);
                  print("${e.value} position $position");
                  print(event.position);
                },
                child: BlurText(
                  key: key,
                  text: e.value,
                  blurValue: e.value.toLowerCase() == "s" ? 10 : 0,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class BlurText extends StatelessWidget {
  const BlurText({
    super.key,
    required this.text,
    this.blurValue = 10,
  });

  final String text;
  final double blurValue;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: blurValue, sigmaY: blurValue),
      child: Text(
        text,
        style: textTheme.displayLarge?.copyWith(
          fontSize: 100,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
