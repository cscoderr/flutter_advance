import 'package:flutter/material.dart';

class LoadingAnimation extends StatefulWidget {
  const LoadingAnimation({super.key, this.count = 3, this.character = '>'});

  final int count;
  final String character;

  @override
  State<LoadingAnimation> createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<LoadingAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )
      ..forward()
      ..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Wrap(
          spacing: 3,
          children: List.generate(widget.count, (index) {
            final opacity = CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                index / widget.count,
                1.0,
                curve: Curves.easeInOut,
              ),
            );
            return FadeTransition(
              opacity: opacity,
              child: Text(
                widget.character,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
              ),
            );
          }),
        );
      },
    );
  }
}
