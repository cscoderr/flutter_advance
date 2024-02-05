import 'package:animation_playground/core/core.dart';
import 'package:flutter/material.dart';

class AnimatedCircularProgressBar extends StatefulWidget {
  const AnimatedCircularProgressBar({
    super.key,
    this.onCompleted,
  });

  final VoidCallback? onCompleted;

  @override
  State<AnimatedCircularProgressBar> createState() =>
      _AnimatedCircularProgressBarState();
}

class _AnimatedCircularProgressBarState
    extends State<AnimatedCircularProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      upperBound: 360.radians,
      duration: const Duration(seconds: 3),
    )..forward();
    _animationController.addStatusListener(_onStatusChanged);
  }

  void _onStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onCompleted?.call();
    }
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
        return CustomPaint(
          painter: CircularProgressPainter(
            _animationController.value,
          ),
        );
      },
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  CircularProgressPainter(this.progress);
  final double progress;
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    const double circleRadius = 70;
    const double arcSize = circleRadius * 2;

    final innerCirclePaint = Paint()
      ..color = Colors.green.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    final progressCirclePaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10;
    canvas.drawCircle(center, circleRadius, innerCirclePaint);
    canvas.drawArc(
      Rect.fromCenter(center: center, width: arcSize, height: arcSize),
      0.radians,
      progress,
      false,
      progressCirclePaint,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) =>
      progress != oldDelegate.progress;
}
