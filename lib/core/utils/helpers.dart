import 'dart:math' as math;

import 'package:animation_playground/core/core.dart';
import 'package:flutter/material.dart';

Offset toPolar(Offset center, int index, int total, double radius) {
  final theta = index * total.stepsInAngle;
  final dx = radius * math.cos(theta);
  final dy = radius * math.sin(theta);
  return Offset(dx, dy) + center;
}

Size getTextSize(BuildContext context, double fontSize, [text = ""]) {
  final TextPainter textPainter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout(
      minWidth: 0,
      maxWidth: MediaQuery.of(context).size.width,
    );
  return textPainter.size;
}
