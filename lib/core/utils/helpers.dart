import 'dart:math' as math;

import 'package:animation_playground/core/core.dart';
import 'package:flutter/material.dart';

Offset toPolar(Offset center, int index, int total, double radius) {
  final theta = index * total.stepsInAngle;
  final dx = radius * math.cos(theta);
  final dy = radius * math.sin(theta);
  return Offset(dx, dy) + center;
}
