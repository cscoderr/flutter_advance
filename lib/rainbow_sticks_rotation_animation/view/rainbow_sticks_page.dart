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
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return CustomPaint(
            painter: _CiclePainter(
              animationController: _animationController,
            ),
            size: MediaQuery.of(context).size,
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_animationController.status == AnimationStatus.completed) {
            _animationController.reverse();
          } else {
            _animationController.forward();
          }
        },
        label: const Text('Animate'),
        icon: const Icon(Icons.play_arrow),
      ),
    );
  }
}

class _CiclePainter extends CustomPainter {
  _CiclePainter({
    required AnimationController animationController,
  }) : _animationController = animationController;
  final AnimationController _animationController;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white60
      ..strokeWidth = 1;

    double innerCircleRadius = 35;
    double outerCircleRaius = 170;
    double angleDegree = 360;
    double circleCount = 360 / 18;

    for (var i = 0; i < angleDegree; i += 18) {
      final index = (i / 18) / 2;
      final startInterval = index * 0.075;
      final endInterval = (index + 0.5) * 0.095;
      print(
          'index $index : startInterval $startInterval - endInterval $endInterval');
      final animation = Tween(begin: 0.0, end: math.pi).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            startInterval,
            endInterval,
            curve: Curves.easeInOut,
          ),
        ),
      );

      final innerCirclePoint =
          toPolar(size.center(Offset.zero), i.radians, innerCircleRadius);

      final outerCirclePoint =
          toPolar(size.center(Offset.zero), i.radians, outerCircleRaius);

      final xCenter = (innerCirclePoint.dx + outerCirclePoint.dx) / 2;
      final yCenter = (innerCirclePoint.dy + outerCirclePoint.dy) / 2;

      canvas
        ..save()
        ..translate(xCenter, yCenter)
        ..rotate(animation.value)
        ..translate(-xCenter, -yCenter);

      canvas.drawLine(innerCirclePoint, outerCirclePoint, linePaint);

      _drawCircle(canvas, innerCirclePoint, _innerCircleColor(i));

      _drawCircle(canvas, outerCirclePoint, _outerCircleColor(i));

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _CiclePainter oldDelegate) => true;

  Color _innerCircleColor(int index) {
    if (index > 0 && index <= 90) {
      return Colors.blue;
    } else if (index > 60 && index <= 180) {
      return Colors.pink;
    } else if (index > 140 && index <= 270) {
      return Colors.cyan;
    } else {
      return Colors.indigo;
    }
  }

  Color _outerCircleColor(int index) {
    if (index > 0 && index <= 90) {
      return Colors.yellowAccent;
    } else if (index > 60 && index <= 180) {
      return Colors.lightGreenAccent;
    } else if (index > 140 && index <= 270) {
      return Colors.redAccent;
    } else {
      return Colors.orangeAccent;
    }
  }

  void _drawCircle(Canvas canvas, Offset offset, Color color) {
    final paint = Paint()..color = color;
    canvas.drawCircle(offset, 7, paint);
  }
}

Offset toPolar(Offset center, double radians, double radius) {
  return center +
      Offset(radius * math.cos(radians), radius * math.sin(radians));
}

extension NumX<T extends num> on T {
  double get radians => (this * math.pi) / 180.0;
}
