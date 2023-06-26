import 'dart:math';

import 'package:flutter/material.dart';

class WaveSlideIcon extends StatelessWidget {
  const WaveSlideIcon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      width: 60,
      child: Stack(
        children: [
          Positioned(
            top: 2,
            bottom: 0,
            left: 0,
            child: Transform.rotate(
              angle: (180 * pi) / 180,
              child: const Icon(
                Icons.play_arrow,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: 10,
            bottom: 10,
            child: Container(
              width: 30,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
