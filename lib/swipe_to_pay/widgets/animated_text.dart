import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';

class AnimatedText extends StatelessWidget {
  const AnimatedText({
    super.key,
    required this.text,
    this.ondelete,
  });

  final String text;
  final VoidCallback? ondelete;

  String get _formatText {
    final parsedText = text.replaceAll('x', '');
    final formattedText = parsedText.isNotEmpty
        ? NumberFormat.currency(symbol: '', decimalDigits: 0)
            .format(int.tryParse(parsedText) ?? 0)
            .toString()
        : '';
    return text.contains('x') ? '${formattedText}x' : formattedText;
  }

  String _index(int index) {
    int mainIndex = 0;
    if (_formatText[index] == ',') {
      return '$index${_formatText[index]}';
    }

    for (var i = 0; i < index; i++) {
      if (_formatText[i] == ',') continue;
      mainIndex++;
    }
    return '$mainIndex${_formatText[index]}';
  }

  @override
  Widget build(BuildContext context) {
    final children = List.generate(_formatText.length, (index) {
      final char = _formatText[index];
      return AnimatedChar(
        key: ValueKey('_animated_text_${_index(index)}'),
        char: char,
        text: _formatText,
        index: index,
        onDelete: ondelete,
      );
    });

    return Row(
      children: children,
    );
  }
}

class AnimatedChar extends StatefulWidget {
  const AnimatedChar({
    super.key,
    required this.char,
    this.text = '',
    this.index = 0,
    this.onDelete,
    this.deleteCharacter = 'x',
  });

  final String char;
  final String text;
  final int index;
  final String deleteCharacter;
  final VoidCallback? onDelete;

  @override
  State<AnimatedChar> createState() => _AnimatedCharState();
}

class _AnimatedCharState extends State<AnimatedChar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      reverseDuration: const Duration(milliseconds: 150),
    );
    _slideAnimation =
        Tween(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.char != widget.deleteCharacter) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AnimatedChar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final lastChar = widget.text.substring(widget.text.length - 1);
    final charToDeleteIndex = widget.text.indexOf(lastChar) - 1;
    if (lastChar == widget.deleteCharacter &&
        widget.index == charToDeleteIndex) {
      _animationController.reverse().whenComplete(
          () => SchedulerBinding.instance.addPostFrameCallback(_ondelete));
    }
  }

  void _ondelete(_) {
    widget.onDelete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Text(
              widget.char,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        );
      },
    );
  }
}
