import 'dart:math' as math;

import 'package:animation_playground/gen/assets.gen.dart';
import 'package:animation_playground/rainbow_sticks/rainbow_sticks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class TarotScrollPage extends StatefulWidget {
  const TarotScrollPage({super.key});

  static PageRoute route() =>
      MaterialPageRoute(builder: (context) => const TarotScrollPage());

  @override
  State<TarotScrollPage> createState() => _TarotScrollPageState();
}

class _TarotScrollPageState extends State<TarotScrollPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  final _totalCard = 50;
  double angle = 0;
  int prevPosInt = 1;

  void runDeceleration(double velocity) {
    final Simulation simulation = FrictionSimulation(.08, angle + 1, velocity);
    _animationController.animateWith(simulation);
  }

  @override
  void initState() {
    _animationController = AnimationController.unbounded(vsync: this);
    _animationController.addListener(() {
      if ((angle.toInt() - _animationController.value.toInt()) == 0) {
        _animationController.stop();
      } else {
        setState(() {
          angle = _animationController.value.toInt().toDouble();
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        title: const Text('Tarot Scroll'),
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.biggest;
            final center = size.center(Offset.zero);
            return Stack(
              alignment: Alignment.center,
              children: List.generate(
                _totalCard,
                (index) {
                  final radius = math.max(
                      ((50 * 0.5) * _totalCard) / (math.pi * 2),
                      size.width / 2);
                  final theta = index * _totalCard.stepsInAngle;
                  final x = (math.cos(theta) * radius) + center.dx;
                  final y = (math.sin(theta) * radius) - 100;
                  return Positioned(
                    left: x,
                    bottom: y,
                    child: Container(
                      width: 50,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        image: DecorationImage(
                          image: Assets.images.img.provider(),
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(color: Colors.white, width: 5),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class TarotCard extends StatelessWidget {
  const TarotCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100 * 0.6,
      height: 100,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          image: DecorationImage(
            image: Assets.images.img.provider(),
            fit: BoxFit.cover,
          ),
          border: Border.all(color: Colors.white, width: 5)),
    );
  }
}

class X1Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // create a bounding square, based on the centre and radius of the arc
    Rect rect = Rect.fromCircle(
      center: const Offset(165.0, 55.0),
      radius: 300.0,
    );

    // a fancy rainbow gradient
    final Gradient gradient = RadialGradient(
      colors: <Color>[
        Colors.green.withOpacity(1.0),
        Colors.green.withOpacity(0.3),
        Colors.yellow.withOpacity(0.2),
        Colors.red.withOpacity(0.1),
        Colors.red.withOpacity(0.0),
      ],
      stops: const [
        0.0,
        0.5,
        0.7,
        0.9,
        1.0,
      ],
    );

    // create the Shader from the gradient and the bounding square
    final Paint paint = Paint()..shader = gradient.createShader(rect);

    // and draw an arc
    canvas.drawArc(rect, math.pi / 5, math.pi, false, paint);
  }

  @override
  bool shouldRepaint(X1Painter oldDelegate) {
    return true;
  }
}
