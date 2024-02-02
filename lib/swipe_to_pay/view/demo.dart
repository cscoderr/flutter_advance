import 'package:animation_playground/animated_progress_bar.dart';
import 'package:animation_playground/swipe_to_pay/swipe_to_pay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class SwipeToPayPage extends StatefulWidget {
  const SwipeToPayPage({super.key});

  static PageRoute route() =>
      MaterialPageRoute(builder: (_) => const SwipeToPayPage());

  @override
  State<SwipeToPayPage> createState() => _SwipeToPayPageState();
}

class _SwipeToPayPageState extends State<SwipeToPayPage> {
  late final TextEditingController keyboardText;
  bool isSuccessful = false;
  final _sliderKey = GlobalKey();
  double _sliderWidth = 0.0;
  double _maxSliderWidth = 0.0;
  final double _minSliderWidth = 70;
  final double _containerHeight = 65;
  double _maxDragExtent = 0.0;

  @override
  void initState() {
    super.initState();
    keyboardText = TextEditingController();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      final renderBox =
          _sliderKey.currentContext?.findRenderObject() as RenderBox?;
      setState(() {
        _sliderWidth = renderBox?.size.width ?? 0.0;
        _maxSliderWidth = _sliderWidth - _minSliderWidth;
        _maxDragExtent = _maxSliderWidth * 0.85;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Stack(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const Spacer(),
              if (!isSuccessful)
                Positioned.fill(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: Column(
                    children: [
                      const Text('Enter Amount'),
                      TextField(
                        controller: keyboardText,
                        showCursor: false,
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                      KeypadWidget(
                        onKeyPressed: (value) {
                          if (value == 'x') {
                            keyboardText.text =
                                keyboardText.text.removeLastChar;
                          } else if (value == '.') {
                            keyboardText.text +=
                                !keyboardText.text.contains('.') ? value : "";
                          } else {
                            keyboardText.text += value;
                          }
                        },
                      ),
                    ],
                  ),
                ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                top: isSuccessful ? size.height * 0.15 : 0,
                curve: Curves.easeInOut,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    '\u20A620,000',
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),

              const Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                left: 0,
                child: _AnimatedProgressBar(),
              ),

              if (1 == 2)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 1000),
                  top: 0,
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: Offstage(
                    offstage: !isSuccessful,
                    child: Center(
                      child: AnimatedSlide(
                        offset: isSuccessful
                            ? Offset.zero
                            : const Offset(2.1, 5.49),
                        duration: const Duration(milliseconds: 1000),
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 1000),
                          scale: isSuccessful ? 4 : 1,
                          child: const PaymetIconWidget(isActive: true),
                        ),
                      ),
                    ),
                  ),
                ),
              // const Spacer(),
              Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: PaymentSliderWidget(
                  key: _sliderKey,
                  containerHeight: _containerHeight,
                  maxDragExtent: _maxDragExtent,
                  maxSliderWidth: _maxSliderWidth,
                  onComplete: (value) {
                    setState(() {
                      isSuccessful = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedProgressBar extends StatefulWidget {
  const _AnimatedProgressBar({
    super.key,
  });

  @override
  State<_AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<_AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      upperBound: 360.radians,
      duration: const Duration(milliseconds: 10000),
    );

    _animationController.forward();
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
        return CustomPaint(
          painter: CircularProgressPainter(
            _animationController.value,
          ),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _animationController.status == AnimationStatus.completed
                ? 1
                : 0,
            child: const Icon(
              Icons.check,
              size: 70,
              color: Colors.green,
            ),
          ),
        );
      },
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  CircularProgressPainter(this.progress);
  final double progress;
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final innerCirclePaint = Paint()
      ..color = Colors.green.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    final progressCirclePaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10;
    canvas.drawCircle(center, 100, innerCirclePaint);
    canvas.drawArc(
      Rect.fromCenter(center: center, width: 200, height: 200),
      0.radians,
      progress,
      false,
      progressCirclePaint,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) => true;
}
