import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class MainImageStack extends StatelessWidget {
  const MainImageStack({
    super.key,
    required this.rect,
    required this.innerLineHeight,
    required this.image,
    required this.midHeightAnimation,
    required this.fullHeightAnimation,
    required this.imagePath,
  });

  final Rect rect;
  final double innerLineHeight;
  final ui.Image image;
  final Animation midHeightAnimation;
  final Animation fullHeightAnimation;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([midHeightAnimation, fullHeightAnimation]),
      builder: (context, child) {
        return Stack(
          children: [
            AnimatedPositioned.fromRect(
              duration: const Duration(milliseconds: 300),
              rect: rect,
              child: Transform.translate(
                offset: Offset(
                    0, midHeightAnimation.value + fullHeightAnimation.value),
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
                  child: Image.asset(
                    imagePath,
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
