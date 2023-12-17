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
              children: words.asMap().entries.map((e) {
                return BlurText(
                  text: e.value,
                  index: e.key,
                  offset: _offset,
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

extension IterableEx<T> on Iterable<T> {
  Iterable<Widget> inBetween(Widget seperator) {
    final items = <Widget>[];
    for (var i = 0; i < length; i++) {
      items.add(toList()[i] as Widget);
      items.add(seperator);
    }
    print(items);
    return items;
  }
}

class BlurText extends StatefulWidget {
  const BlurText({
    super.key,
    required this.text,
    required this.offset,
    required this.index,
    this.fontSize = 50,
  });

  final String text;
  final Offset offset;
  final int index;
  final double fontSize;

  @override
  State<BlurText> createState() => _BlurTextState();
}

class _BlurTextState extends State<BlurText> {
  double value = 10;
  final GlobalKey _key = GlobalKey();

  Size _textDetails(BuildContext context, [text = ""]) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: widget.fontSize,
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

  bool _shouldApplyBlur(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;

    // Get the global position of the text widget
    final Offset globalPosition = renderBox.localToGlobal(Offset.zero);

    // Get the size of the text widget
    final Size textSize = renderBox.size;

    final size = _textDetails(context, widget.text);

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
        scale: shouldApplyBlur ? 1 : 1.1,
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
