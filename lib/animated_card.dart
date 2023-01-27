import 'package:flutter/material.dart';

class AnimatedCard extends StatefulWidget {
  const AnimatedCard({Key? key}) : super(key: key);

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 70,
                  width: 70,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.message,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  'Perfect for learning how flutter impeller works, prototyping a new idea, or creating a demo to share online',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  'Learn More',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedCardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    throw UnimplementedError();
  }
}
