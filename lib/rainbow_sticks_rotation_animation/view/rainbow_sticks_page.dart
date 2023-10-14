import 'dart:math' as math;

import 'package:flutter/material.dart';

class RainbowSticksPage extends StatefulWidget {
  const RainbowSticksPage({super.key});

  @override
  State<RainbowSticksPage> createState() => _RainbowSticksPageState();
}

class _RainbowSticksPageState extends State<RainbowSticksPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation _rotationAnimation;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _rotationAnimation = TweenSequence([
      TweenSequenceItem(
          tween: Tween(begin: 0.radians, end: 360.radians), weight: 1)
    ]).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
      ),
    );
    // _animationController.repeat();

    _animationController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomPaint(
        painter: CiclePainter(
          animationController: _animationController,
          rotation: _rotationAnimation.value,
        ),
        size: MediaQuery.of(context).size,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          print(_animationController.status);
          if (_animationController.status == AnimationStatus.completed) {
            _animationController.reset();
          } else {
            _animationController.forward();
          }
        },
        label: const Text('Start Animation'),
        icon: const Icon(Icons.play_arrow),
      ),
    );
  }
}

class CiclePainter extends CustomPainter {
  CiclePainter({
    required this.animationController,
    required this.rotation,
  });
  final AnimationController animationController;
  final double rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;

    double innerCircleRadius = 35;
    double outerCircleRaius = 170;
    double count = 20;
    final angleStep = (math.pi * 2) / count;

    final center = size.center(Offset.zero);

    final animation = Tween(begin: 0, end: math.pi);

    for (var i = 0; i < 10; i++) {
      final angle = i * angleStep;

      final x = center.dx + math.cos(angle) * innerCircleRadius;
      final y = center.dy + math.sin(angle) * innerCircleRadius;

      final outerX = center.dx + math.cos(angle) * outerCircleRaius;
      final outerY = center.dy + math.sin(angle) * outerCircleRaius;

      final midX = (x + outerX) / 2;
      final midY = (y + outerY) / 2;

      final animation0 = animation.animate(
        CurvedAnimation(
          parent: animationController,
          curve: Interval(
            (i / 20) * 0.5,
            1.0,
          ),
        ),
      );

      canvas
        ..save()
        ..translate(midX, midY)
        ..rotate(animation0.value.toDouble())
        ..translate(-midX, -midY);

      canvas.drawLine(
        Offset(x, y),
        Offset(outerX, outerY),
        linePaint,
      );

      canvas.drawCircle(
        Offset(x, y),
        7,
        Paint()..color = _innerColor(i),
      );

      canvas.drawCircle(
        Offset(outerX, outerY),
        7,
        Paint()..color = _outerColor(i),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  Color _innerColor(int index) {
    if (index > 0 && index <= 5) {
      return Colors.blue;
    } else if (index > 5 && index <= 10) {
      return Colors.pink;
    } else if (index > 10 && index <= 15) {
      return Colors.cyan;
    } else {
      return Colors.indigo;
    }
  }

  Color _outerColor(int index) {
    if (index > 0 && index <= 5) {
      return Colors.yellowAccent;
    } else if (index > 5 && index <= 10) {
      return Colors.lightGreenAccent;
    } else if (index > 10 && index <= 15) {
      return Colors.redAccent;
    } else {
      return Colors.orangeAccent;
    }
  }
}

Offset toPolar(Offset center, double radians, double radius) {
  return center +
      Offset(radius * math.cos(radians), radius * math.sin(radians));
}

extension NumX<T extends num> on T {
  double get radians => (this * math.pi) / 180.0;
}
