import 'dart:math' as math;

import 'package:flutter/material.dart';

class TextShimmerWave extends StatefulWidget {
  const TextShimmerWave({super.key});

  static PageRoute route() =>
      MaterialPageRoute(builder: (_) => const TextShimmerWave());

  @override
  State<TextShimmerWave> createState() => _TextShimmerWaveState();
}

class _TextShimmerWaveState extends State<TextShimmerWave>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _animationController
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
    final textTheme = Theme.of(context).textTheme;
    const text = 'Hi, how are you?';
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'French',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      'Salut comment ça va',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Divider(),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'English',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF56CED0),
                                ),
                              ),
                              AnimatedBuilder(
                                  animation: _animationController,
                                  builder: (context, child) {
                                    return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: List.generate(
                                        text.length,
                                        (index) => TextShimmer(
                                          key: ValueKey('$index'),
                                          animationController:
                                              _animationController,
                                          length: text.length,
                                          char: text[index],
                                          index: index + 1,
                                        ),
                                      ),
                                    );
                                  }),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.pause_circle_rounded,
                          color: Color(0xFF3A777B),
                          size: 50,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TextShimmer extends StatefulWidget {
  const TextShimmer({
    super.key,
    required this.animationController,
    required this.length,
    required this.char,
    required this.index,
  });
  final AnimationController animationController;
  final int length;
  final String char;
  final int index;

  @override
  State<TextShimmer> createState() => _TextShimmerState();
}

class _TextShimmerState extends State<TextShimmer> {
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    double startValue = (widget.index / widget.length) * 0.5;
    double endValue = math.min(startValue + 0.2, 1.0);
    _scaleAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.25)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50.0,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.25, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50.0,
      ),
    ]).animate(
      CurvedAnimation(
        parent: widget.animationController,
        curve: Interval(startValue, endValue),
      ),
    );

    _colorAnimation = TweenSequence([
      TweenSequenceItem(
        tween: ColorTween(
          begin: const Color(0xFF56CED0),
          end: const Color(0xFFbcfbff),
        ),
        weight: 50.0,
      ),
      TweenSequenceItem(
        tween: ColorTween(
          begin: const Color(0xFFbcfbff),
          end: const Color(0xFF3A777B),
        ),
        weight: 50.0,
      ),
    ]).animate(
      CurvedAnimation(
        parent: widget.animationController,
        curve: Interval(startValue, endValue),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Text(
        widget.char,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: _colorAnimation.value!,
            ),
      ),
    );
  }
}
