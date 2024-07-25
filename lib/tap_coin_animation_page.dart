import 'package:animation_playground/gen/assets.gen.dart';
import 'package:flutter/material.dart';

class TapCoinAnimationPage extends StatefulWidget {
  const TapCoinAnimationPage({super.key});

  static PageRoute route() =>
      MaterialPageRoute(builder: (context) => const TapCoinAnimationPage());

  @override
  State<TapCoinAnimationPage> createState() => _TapCoinAnimationPageState();
}

class _TapCoinAnimationPageState extends State<TapCoinAnimationPage>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '190,767,454',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 30),
          Stack(
            children: [
              GestureDetector(
                onTap: () {},
                child: Container(
                  height: 250,
                  width: 250,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Colors.black,
                        Colors.blue,
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue, width: 15),
                  ),
                  child: Assets.images.dash.image(),
                ),
              ),
              Align(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    5,
                    (index) {
                      return Text(
                        '15',
                        style:
                            Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }
}

class CirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    canvas.drawCircle(
      Offset(center.dx, center.dy),
      50,
      Paint()
        ..color = Colors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10,
    );
  }

  @override
  bool shouldRepaint(CirclePainter oldDelegate) => false;
}
