import 'dart:math' as math;

import 'package:flutter/material.dart';

class AnimatedLock extends StatefulWidget {
  const AnimatedLock({Key? key}) : super(key: key);

  @override
  State<AnimatedLock> createState() => _AnimatedLockState();
}

class _AnimatedLockState extends State<AnimatedLock>
    with SingleTickerProviderStateMixin {
  late bool isLocked;
  late AnimationController _controller;
  late Animation<double> _arcAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..reverse();
    _arcAnimation =
        Tween(begin: -180 * math.pi / 180, end: -90 * math.pi / 180).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticInOut),
    );
    isLocked = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black26,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: LockPainter(
                arcAnimation: _arcAnimation,
                isLocked: isLocked,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isLocked ? "Locked" : "Unlock",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 10),
                Switch.adaptive(
                  value: isLocked,
                  onChanged: (value) {
                    setState(() {
                      isLocked = !isLocked;
                      if (isLocked) {
                        _controller.reverse();
                      } else {
                        _controller.forward();
                      }
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LockPainter extends CustomPainter {
  LockPainter({
    required this.arcAnimation,
    this.isLocked = false,
  });

  final Animation<double> arcAnimation;

  final bool isLocked;
  @override
  void paint(Canvas canvas, Size size) {
    // main rect paint
    final paint = Paint()
      ..color = isLocked ? Colors.white : Colors.green
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    //overlay paint
    final overlayPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    //arc paint
    final arcPaint = Paint()
      ..color = isLocked ? Colors.grey : Colors.green
      ..strokeWidth = 20
      ..shader
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    //draw arc of a circle
    canvas.drawArc(
      Rect.fromCircle(center: size.center(const Offset(0, -125)), radius: 70),
      (isLocked ? 0 : 30) * math.pi / 180,
      arcAnimation.value,
      false,
      arcPaint,
    );

    //use to prevent arc rounded edge from showing
    final overlayPath = Path().drawCustomRRect(size);

    //main RRect
    final path = Path().drawCustomRRect(size);

    //draw both overlay and  RRect on canvas

    canvas.drawPath(overlayPath, overlayPaint);
    if (!isLocked) {
      canvas.drawShadow(path, Colors.green.withOpacity(0.5), 3, true);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

extension CustomRectX on Path {
  Path drawCustomRRect(Size size) {
    final path = Path();
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: size.center(Offset.zero),
          width: size.width / 2,
          height: size.height / 4,
        ),
        const Radius.circular(20),
      ),
    );
    return path;
  }
}
