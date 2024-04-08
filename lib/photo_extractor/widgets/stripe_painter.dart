// ignore_for_file: depend_on_referenced_packages, deprecated_member_use

import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math.dart' as vector;

class StripePainter extends CustomPainter {
  final ui.Image image;
  final AnimationController animationController;
  final double stripeWidth;
  final int numberOfStripe;
  final double imageHeight;

  StripePainter(
    this.image,
    this.animationController, {
    required this.stripeWidth,
    required this.numberOfStripe,
    required this.imageHeight,
  }) : super(
          repaint: Listenable.merge([
            animationController,
          ]),
        );

  @override
  void paint(Canvas canvas, Size size) {
    const spaceBetweenStripes = 10;
    const offsetYExtra = 15;
    final stripeWidthWithSpace = stripeWidth - spaceBetweenStripes;

    final paint = Paint()
      ..shader = ImageShader(
        image,
        TileMode.clamp,
        TileMode.clamp,
        Matrix4.identity().storage,
      );
    for (var i = 0; i < numberOfStripe; i++) {
      final x = i * stripeWidth;
      final rect = Rect.fromLTWH(
        x,
        0,
        stripeWidthWithSpace,
        imageHeight - offsetYExtra,
      );
      final (vertices, textures, indices) =
          generateTrianglePoints(rect, 20, i / numberOfStripe);

      final animatedVertices = calculateAnimatedVertices(
        vertices,
        animationController.value,
      );

      canvas.save();
      canvas.translate(5, 0);
      canvas.drawVertices(
        ui.Vertices(
          VertexMode.triangles,
          animatedVertices,
          textureCoordinates: textures,
          indices: indices,
        ),
        BlendMode.src,
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(StripePainter oldDelegate) =>
      animationController.value != oldDelegate.animationController.value ||
      image != oldDelegate.image ||
      stripeWidth != oldDelegate.stripeWidth ||
      numberOfStripe != oldDelegate.numberOfStripe ||
      imageHeight != oldDelegate.imageHeight;

  List<Offset> calculateAnimatedVertices(
      List<Offset> vertices, double animationValue) {
    final noise = vector.SimplexNoise();
    final animatedVertices = vertices.map((v) {
      final d = (-1 * animationValue * 8) *
          noise.noise2D(Random().nextInt(10000) * 0.0004 * 2,
              vertices.indexOf(v).toDouble());
      return Offset(v.dx + d, v.dy + d);
    }).toList();
    return animatedVertices;
  }

  (List<Offset>, List<Offset>, List<int>) generateTrianglePoints(
    Rect rect,
    int totalTriangle,
    double z,
  ) {
    final vertices = <Offset>[];
    final textures = <Offset>[];
    final indices = <int>[];

    const a = 5;
    const f = 1;

    final rectx = rect.left;
    final recty = rect.top;
    final triangleWidth = rect.width;
    final triangleHeight = rect.height / totalTriangle;
    final noise = vector.SimplexNoise();

    for (var k = 0; k <= totalTriangle; k++) {
      for (var j = 0.0; j <= 1; j++) {
        final point = Offset(
          rectx + j * triangleWidth,
          recty + k * triangleHeight,
        );
        textures.add(point);
        final d = a * noise.noise3D((f * k) / totalTriangle, f * j, z);
        vertices.add(Offset(point.dx + d, point.dy + d));
      }
    }

    for (var i = 0; i < totalTriangle; i++) {
      final topLeftIndex = i * 2;
      final topRightIndex = topLeftIndex + 1;
      final bottomLeftIndex = topLeftIndex + 2;
      final bottomRightIndex = bottomLeftIndex + 1;

      // Create two triangles for each square and add their indices to the list
      indices.addAll([topLeftIndex, topRightIndex, bottomLeftIndex]);
      indices.addAll([bottomLeftIndex, topRightIndex, bottomRightIndex]);
    }
    return (vertices, textures, indices);
  }
}
