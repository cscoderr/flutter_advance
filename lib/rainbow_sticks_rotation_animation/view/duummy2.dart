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
        vsync: this, duration: const Duration(milliseconds: 1000));
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
    double angleDegree = 360;

    for (var i = 0; i < angleDegree; i += 18) {
      final animation = Tween(begin: 0, end: 180.radians).animate(
        CurvedAnimation(
          parent: animationController,
          curve: Interval(
            i / 360,
            1,
          ),
        ),
      );

      final midPointX = (toPolar(
                size.center(Offset.zero),
                i.radians,
                innerCircleRadius,
              ).dx +
              toPolar(
                size.center(Offset.zero),
                i.radians,
                outerCircleRaius,
              ).dx) /
          2;
      final midPointY = (toPolar(
                size.center(Offset.zero),
                i.radians,
                innerCircleRadius,
              ).dy +
              toPolar(
                size.center(Offset.zero),
                i.radians,
                outerCircleRaius,
              ).dy) /
          2;

      canvas
        ..save()
        ..transform(Matrix4.identity().storage)
        ..translate(midPointX, midPointY)
        ..rotate(animation.value.toDouble())
        ..translate(-midPointX, -midPointY);
      canvas.drawLine(
        toPolar(
          size.center(Offset.zero),
          i.radians,
          innerCircleRadius,
        ),
        toPolar(
          size.center(Offset.zero),
          i.radians,
          outerCircleRaius,
        ),
        linePaint,
      );

      _drawCircle(
        canvas,
        size,
        innerCircleRadius,
        i,
        i.radians,
        _innerColor(i),
      );

      _drawCircle(
        canvas,
        size,
        outerCircleRaius,
        i,
        i.radians,
        _outerColor(i),
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  Color _innerColor(int index) {
    if (index > 0 && index <= 80) {
      return Colors.blue;
    } else if (index > 60 && index <= 160) {
      return Colors.pink;
    } else if (index > 140 && index <= 240) {
      return Colors.cyan;
    } else {
      return Colors.indigo;
    }
  }

  Color _outerColor(int index) {
    if (index > 0 && index <= 80) {
      return Colors.yellowAccent;
    } else if (index > 60 && index <= 160) {
      return Colors.lightGreenAccent;
    } else if (index > 140 && index <= 240) {
      return Colors.redAccent;
    } else {
      return Colors.orangeAccent;
    }
  }

  void _drawCircle(Canvas canvas, Size size, double radius, int i,
      double radians, Color color) {
    final paint = Paint()..color = color;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCircle(
          center: toPolar(
            size.center(Offset.zero),
            radians,
            radius,
          ),
          radius: 8,
        ),
        const Radius.circular(50),
      ),
      paint,
    );
  }
}

Offset toPolar(Offset center, double radians, double radius) {
  return center +
      Offset(radius * math.cos(radians), radius * math.sin(radians));
}

extension NumX<T extends num> on T {
  double get radians => (this * math.pi) / 180.0;
}
