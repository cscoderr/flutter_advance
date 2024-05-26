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

int weighted(List<int> arr, List<int> weights, {bool? trim}) {
  if (arr.length != weights.length) {
    throw RangeError("Chance: Length of array and weights must match");
  }

  // scan weights array and sum valid entries
  int sum = 0;
  int val;
  for (var weightIndex = 0; weightIndex < weights.length; ++weightIndex) {
    val = weights[weightIndex];
    if (val.isNaN) {
      throw RangeError("Chance: All weights must be numbers");
    }

    if (val > 0) {
      sum += val;
    }
  }

  if (sum == 0) {
    throw RangeError("Chance: No valid entries in array weights");
  }

  // select a value within range
  var selected = math.Random().nextDouble() * sum;

  // find array entry corresponding to selected value
  var total = 0;
  var lastGoodIdx = -1;
  int? chosenIdx;
  for (var weightIndex = 0; weightIndex < weights.length; ++weightIndex) {
    val = weights[weightIndex];
    total += val;
    if (val > 0) {
      if (selected <= total) {
        chosenIdx = weightIndex;
        break;
      }
      lastGoodIdx = weightIndex;
    }

    // handle any possible rounding error comparison to ensure something is picked
    if (weightIndex == (weights.length - 1)) {
      chosenIdx = lastGoodIdx;
    }
  }

  int chosen = arr[chosenIdx ?? 0];
  trim = trim ?? false;
  if (trim) {
    arr.removeAt(chosenIdx!);
    weights.removeAt(chosenIdx);
  }

  return chosen;
}
