import 'dart:ui';

import 'package:flutter/material.dart';

class BlurAnimation extends StatefulWidget {
  const BlurAnimation({super.key});

  static PageRoute route() =>
      MaterialPageRoute(builder: (_) => const BlurAnimation());

  @override
  State<BlurAnimation> createState() => _BlurAnimationState();
}

class _BlurAnimationState extends State<BlurAnimation> {
  final text = "FOCUS";
  Offset _offset = Offset.zero;
  @override
  Widget build(BuildContext context) {
    final words = text.split("");
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: GestureDetector(
            onPanStart: (details) {
              setState(() {
                _offset = details.globalPosition;
              });
            },
            onPanUpdate: (details) {
              setState(() {
                _offset = details.globalPosition;
              });
            },
            onPanEnd: (details) {
              setState(() {
                _offset = Offset.zero;
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: words
                  .map((e) => BlurText(
                        text: e,
                        offset: _offset,
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class BlurText extends StatefulWidget {
  const BlurText({
    super.key,
    required this.text,
    required this.offset,
    this.fontSize = 50,
  });

  final String text;
  final Offset offset;
  final double fontSize;

  @override
  State<BlurText> createState() => _BlurTextState();
}

class _BlurTextState extends State<BlurText> {
  final GlobalKey _key = GlobalKey();

  bool _shouldApplyBlur(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return true;

    final Offset globalPosition = renderBox.localToGlobal(Offset.zero);
    final textSize = renderBox.size;
    final xInPosition = globalPosition.dx < widget.offset.dx &&
        globalPosition.dx + textSize.width > widget.offset.dx;
    final yInPosition = globalPosition.dy < widget.offset.dy &&
        globalPosition.dy + textSize.height > widget.offset.dy;
    return !(xInPosition && yInPosition);
  }

  @override
  Widget build(BuildContext context) {
    final shouldApplyBlur = _shouldApplyBlur(context);
    return ImageFiltered(
      imageFilter: ImageFilter.blur(
        sigmaX: shouldApplyBlur ? 7 : 0,
        sigmaY: shouldApplyBlur ? 7 : 0,
      ),
      child: AnimatedScale(
        scale: shouldApplyBlur ? 1 : 1.2,
        duration: const Duration(milliseconds: 300),
        child: Text(
          widget.text,
          key: _key,
          style: TextStyle(
            fontSize: widget.fontSize,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
