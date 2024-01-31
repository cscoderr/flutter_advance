import 'dart:math' as math;

import 'package:flutter/material.dart';

class ChrismasTree extends StatefulWidget {
  const ChrismasTree({super.key});

  @override
  State<ChrismasTree> createState() => _ChrismasTreeState();
}

class _ChrismasTreeState extends State<ChrismasTree>
    with SingleTickerProviderStateMixin {
  final List<Chain> chains = [];
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat();

    chains.addAll([
      Chain(
        bulbRadius: 2,
        bulbCount: 100,
        opacity: 1,
        startAngle: 0,
        startColor: const Color(0xfffffffc),
        endColor: const Color(0xfffffffc),
        turnCount: 14,
      ),
      Chain(
        bulbRadius: 50,
        bulbCount: 20,
        opacity: 0.3,
        startAngle: 120,
        startColor: const Color(0xff0ffff0),
        endColor: const Color(0xff0ff0ff),
        turnCount: 14,
      ),
      Chain(
        bulbRadius: 12,
        bulbCount: 50,
        opacity: 0.68,
        startAngle: 240,
        startColor: const Color(0xff0ff0ff),
        endColor: const Color(0xff0ffff0),
        turnCount: -3,
      ),
    ]);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) => CustomPaint(
          painter: ChrimasTreePainter(
              chains: chains, animationController: _animationController),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class ChrimasTreePainter extends CustomPainter {
  ChrimasTreePainter({
    required this.chains,
    required this.animationController,
  });
  final List<Chain> chains;
  final AnimationController animationController;
  @override
  void paint(Canvas canvas, Size size) {
    for (var chain in chains) {
      drawChain(canvas, size, chain);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  void drawChain(Canvas canvas, Size size, Chain chain) {
    final center = size.center(Offset.zero);
    final treeHeight = math.min(size.width, size.height);
    const rotationX = 30;
    const tiltAngle = rotationX / 180 * math.pi;
    final baseRadius = treeHeight * .3;
    double rotationZ = 0;

    for (int i = 0; i < chain.bulbCount; i++) {
      final Paint paint = Paint();

      final progress = math
          .pow(i / (chain.bulbCount - 1),
              math.sqrt(i / (chain.bulbCount - 1)) + 1)
          .toDouble();
      final double turnProgress = (progress * chain.turnCount) % 1;
      final animation =
          animationController.drive(Tween(begin: progress, end: 0.0));
      final sectionRadius = baseRadius * (1 - progress);
      final sectionAngle =
          ((turnProgress * 360 + chain.startAngle + rotationZ) *
                  math.pi /
                  180) %
              (2 * math.pi);
      print(sectionAngle);
      final double opacity =
          math.min(1, math.max(0, math.cos(sectionAngle)) + 0.2);
      final dx = center.dx + (math.sin(sectionAngle) * sectionRadius);
      final dy = center.dy -
          progress * treeHeight * math.sin((90 - rotationX) / 180 * math.pi) +
          sectionRadius * math.sin(tiltAngle) * math.cos(sectionAngle);
      final double bulbRadius = chain.bulbRadius * treeHeight / 1000;

      final Color currentColor = Color.alphaBlend(
        Color.lerp(chain.startColor, chain.endColor, progress)!,
        Colors.white
            .withOpacity(opacity), // Use white as the base color for opacity
      );

      // Opacity
      paint.color = currentColor.withOpacity(chain.opacity);

      canvas.drawCircle(Offset(dx, dy), bulbRadius, paint);
      rotationZ = (rotationZ - 1) % 360;
    }
  }
}

class Chain {
  Chain({
    required this.bulbRadius,
    required this.bulbCount,
    required this.opacity,
    required this.startAngle,
    required this.startColor,
    required this.endColor,
    required this.turnCount,
  });
  final double bulbRadius;
  final int bulbCount;
  final double opacity;
  final int startAngle;
  final Color startColor;
  final Color endColor;
  final int turnCount;
}
