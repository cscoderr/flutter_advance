import 'package:flutter/material.dart';

class RainbowStick {
  RainbowStick({
    required this.innerCirclePoint,
    required this.outerCirclePoint,
    required this.innerColor,
    required this.outerColor,
  });

  final Offset innerCirclePoint;
  final Offset outerCirclePoint;
  final Color innerColor;
  final Color outerColor;

  static const double innerCircleRadius = 35;
  static const double outerCircleRaius = 170;
  static const double circleCount = 20;

  static Color getInnerColor(int index) {
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

  static Color getOuterColor(int index) {
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
}
