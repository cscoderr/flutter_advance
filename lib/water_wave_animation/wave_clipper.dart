import 'package:flutter/material.dart';

class WaveClipper extends CustomClipper<Path> {
  WaveClipper({required this.points});
  final List<Offset> points;
  @override
  Path getClip(Size size) {
    final path = Path();
    path.addPolygon(points, false);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
