import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

ValueNotifier _completedNotifier = ValueNotifier(false);

class SlideToConfirmPage extends StatelessWidget {
  const SlideToConfirmPage({super.key});

  static PageRoute route() =>
      MaterialPageRoute(builder: (context) => const SlideToConfirmPage());

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(
          bottom: 50,
          right: 20,
          left: 20,
        ),
        child: Column(
          children: [
            Expanded(
              child: ValueListenableBuilder(
                  valueListenable: _completedNotifier,
                  builder: (context, completed, child) {
                    return Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        AnimatedImageFiltered(
                          blurAmount: completed ? 0 : 10,
                          duration: const Duration(milliseconds: 500),
                          opacity: completed ? 1 : 0,
                          child: Text(
                            "Confirmed!!!",
                            textAlign: TextAlign.center,
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        AnimatedImageFiltered(
                          blurAmount: completed ? 10 : 0,
                          duration: const Duration(milliseconds: 500),
                          opacity: completed ? 0 : 1,
                          child: Text(
                            "Awaiting Confirmation...",
                            textAlign: TextAlign.center,
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SlideToConfirmWidget(
                  onConfirm: () {
                    _completedNotifier.value = !_completedNotifier.value;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SlideToConfirmWidget extends StatefulWidget {
  const SlideToConfirmWidget({
    super.key,
    this.onConfirm,
  });
  final VoidCallback? onConfirm;

  @override
  State<SlideToConfirmWidget> createState() => _SlideToConfirmWidgetState();
}

class _SlideToConfirmWidgetState extends State<SlideToConfirmWidget> {
  final _sliderHeight = 70.0;
  final _knobSize = 60.0;
  final _altSliderHeight = 60.0;
  double _altSliderWidth = 0.0;
  double _dragPosition = 0.0;
  bool _isSliding = false;
  bool _isConfirmed = false;
  double _maxSliderWidth = 0;
  double _maxDragExtent = 0;
  final GlobalKey _confirmTextKey = GlobalKey();
  double _confirmTextWidth = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getConfirmTextSize();
    });
  }

  void _getConfirmTextSize() {
    final renderBox =
        _confirmTextKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _confirmTextWidth = renderBox.size.width;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      _maxSliderWidth = width - _sliderHeight;
      _maxDragExtent = _maxSliderWidth * 0.85;
      _altSliderWidth = width * 0.6;

      double slidingProgress = (_dragPosition / _maxSliderWidth).clamp(0, 1);
      final double confirmTextStart = (_maxSliderWidth - _confirmTextWidth) / 2;
      final double confirmTextEnd = (_maxSliderWidth + _confirmTextWidth) / 2;
      double confirmTextProgress = ((_dragPosition - confirmTextStart) /
              (confirmTextEnd - confirmTextStart))
          .clamp(0.0, 1.0);

      final slidingDuration =
          _isSliding ? Duration.zero : const Duration(milliseconds: 250);
      return GestureDetector(
        onHorizontalDragStart: (details) => _handleDragStart(),
        onHorizontalDragUpdate: (details) => _handleDragUpdate(details),
        onHorizontalDragEnd: (details) => _handleDragEnd(details),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _isConfirmed ? _altSliderWidth : width,
          height: _isConfirmed ? _altSliderHeight : _sliderHeight,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
              )
            ],
            borderRadius: BorderRadius.circular(_maxSliderWidth / 2),
          ),
          child: Stack(
            children: [
              _buildInitialText(),
              _buildSlidingContainer(slidingDuration),
              _buildCompletedText(confirmTextProgress),
              _buildKnob(slidingProgress, slidingDuration),
            ],
          ),
        ),
      );
    });
  }

  void _handleDragStart() {
    setState(
      () {
        _isSliding = true;
        _isConfirmed = false;
      },
    );
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final isLTR = Directionality.of(context) == TextDirection.ltr;
    final newDetails = isLTR ? details.delta.dx : -details.delta.dx;
    setState(() {
      _dragPosition = (_dragPosition + newDetails).clamp(0, _maxSliderWidth);
    });
  }

  void _handleDragEnd(
    DragEndDetails details,
  ) {
    if (_dragPosition < _maxDragExtent) {
      _dragPosition = 0;
    } else {
      _dragPosition = _maxSliderWidth;
      _isConfirmed = true;
      widget.onConfirm?.call();
    }
    _isSliding = false;
    setState(() {});
  }

  Widget _buildInitialText() {
    return const Center(
      child: TextShimmer(text: 'Slide to Pay'),
    );
  }

  Widget _buildCompletedText(double progress) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: const [
              Colors.white,
              Colors.transparent,
            ],
            stops: [progress, progress],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedImageFiltered(
              blurAmount: _isConfirmed ? 0 : 10,
              duration: const Duration(milliseconds: 500),
              opacity: _isConfirmed ? 1 : 0,
              child: Text(
                "Success!",
                style: textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            AnimatedImageFiltered(
              blurAmount: _isConfirmed ? 10 : 0,
              duration: const Duration(milliseconds: 500),
              opacity: _isConfirmed ? 0 : 1,
              child: Text(
                "Confirms Payment",
                key: _confirmTextKey,
                style: textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlidingContainer(Duration slidingDuration) {
    return AnimatedContainer(
      width: _dragPosition + _sliderHeight,
      duration: slidingDuration,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF5AE777),
            Color(0xFF3DD95A),
          ],
        ),
        borderRadius: BorderRadius.circular(_maxSliderWidth / 2),
      ),
    );
  }

  Widget _buildKnob(double progress, Duration slidingDuration) {
    final double knobWidth = _isConfirmed ? _knobSize / 2 : _knobSize;
    //20 is the margin
    final double confirmedKnobStart = _altSliderWidth - knobWidth - 20;
    return AnimatedPositionedDirectional(
      top: 0,
      bottom: 0,
      start: _isConfirmed ? confirmedKnobStart : _dragPosition,
      duration:
          _isConfirmed ? const Duration(milliseconds: 300) : slidingDuration,
      child: AnimatedContainer(
        width: knobWidth,
        duration: const Duration(milliseconds: 300),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black,
        ),
        margin: const EdgeInsetsDirectional.only(start: 5),
        alignment: Alignment.center,
        child: Stack(
          children: [
            AnimatedImageFiltered(
              duration: const Duration(milliseconds: 300),
              blurAmount: progress * 10,
              opacity: 1 - progress,
              child: Icon(
                Icons.keyboard_arrow_right,
                color: Theme.of(context).colorScheme.onPrimary,
                size: _isConfirmed ? _knobSize * 0.25 : _knobSize * 0.5,
              ),
            ),
            AnimatedImageFiltered(
              duration: const Duration(milliseconds: 500),
              blurAmount: (1 - progress) * 10,
              opacity: progress,
              child: Icon(
                Icons.check,
                color: Theme.of(context).colorScheme.onPrimary,
                size: _isConfirmed ? _knobSize * 0.3 : _knobSize * 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedImageFiltered extends StatelessWidget {
  const AnimatedImageFiltered({
    super.key,
    required this.duration,
    required this.child,
    required this.blurAmount,
    required this.opacity,
  });
  final Duration duration;
  final double blurAmount;
  final double opacity;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(
        begin: 0,
        end: blurAmount,
      ),
      curve: Curves.easeOut,
      duration: duration,
      builder: (context, value, child) {
        return Opacity(
          opacity: opacity,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: value,
              sigmaY: value,
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class TextShimmer extends StatelessWidget {
  const TextShimmer({
    super.key,
    required this.text,
  });
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        text.length,
        (index) => _TextShimmerAnimation(
          // key: ValueKey('$index'),
          length: text.length,
          char: text[index],
          index: index + 1,
        ),
      ),
    );
  }
}

class _TextShimmerAnimation extends StatefulWidget {
  const _TextShimmerAnimation({
    required this.length,
    required this.char,
    required this.index,
  });
  final int length;
  final String char;
  final int index;

  @override
  State<_TextShimmerAnimation> createState() => _TextShimmerAnimationState();
}

class _TextShimmerAnimationState extends State<_TextShimmerAnimation>
    with SingleTickerProviderStateMixin {
  late Animation<Color?> _colorAnimation;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )
      ..forward()
      ..repeat();
    double startValue = (widget.index / widget.length) * 0.5;
    double endValue = min(startValue + 0.2, 1.0);

    _colorAnimation = TweenSequence([
      TweenSequenceItem(
        tween: ColorTween(
          begin: Colors.grey,
          end: Colors.grey[300]!,
        ),
        weight: 50.0,
      ),
      TweenSequenceItem(
        tween: ColorTween(
          begin: Colors.grey[300]!,
          end: Colors.grey,
        ),
        weight: 50.0,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(startValue, endValue),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Text(
          widget.char,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: _colorAnimation.value,
                fontWeight: FontWeight.bold,
              ),
        );
      },
    );
  }
}
