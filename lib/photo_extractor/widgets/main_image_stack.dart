import 'dart:ui' as ui;

import 'package:animation_playground/gen/assets.gen.dart';
import 'package:flutter/material.dart';

class MainImageStack extends StatelessWidget {
  const MainImageStack({
    super.key,
    required this.rect,
    required this.innerLineHeight,
    required this.image,
    required this.heightAnimation,
    required this.heightAnimation2,
  });

  final Rect rect;
  final double innerLineHeight;
  final ui.Image image;
  final Animation heightAnimation;
  final Animation heightAnimation2;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([heightAnimation, heightAnimation2]),
      builder: (context, child) {
        return Stack(
          children: [
            AnimatedPositioned.fromRect(
              duration: const Duration(milliseconds: 300),
              rect: rect,
              child: Transform.translate(
                offset:
                    Offset(0, heightAnimation.value + heightAnimation2.value),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 5,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Assets.images.img3.image(
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
