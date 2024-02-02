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

class _SwipeToPayPageState extends State<SwipeToPayPage>
    with TickerProviderStateMixin {
  bool isSuccessful = false;
  final _sliderKey = GlobalKey();
  double _sliderWidth = 0.0;
  double _maxSliderWidth = 0.0;
  final double _minSliderWidth = 70;
  final double _containerHeight = 80;
  double _maxDragExtent = 0.0;
  double _xDragOffet = 0.0;
  bool isSliding = false;
  bool isProgressCompleted = false;

  late final TextEditingController _keyboardTextController;
  late final AnimationController _animationController;
  late final AnimationController _animationController2;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _logoSlideAnimation;
  late final Animation<Offset> _amountSlideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _keyboardTextController = TextEditingController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animationController2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scaleAnimation = Tween(begin: 1.0, end: 5.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _logoSlideAnimation =
        Tween(begin: Offset.zero, end: const Offset(-2.1, -4.7)).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _amountSlideAnimation =
        Tween(begin: Offset.zero, end: const Offset(0, 2)).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _fadeAnimation = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController2,
        curve: const Interval(
          0.0,
          0.5,
          curve: Curves.easeOut,
        ),
      ),
    );
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final renderBox =
          _sliderKey.currentContext?.findRenderObject() as RenderBox?;
      setState(() {
        _sliderWidth = renderBox?.size.width ?? 0.0;
        _maxSliderWidth = _sliderWidth - _minSliderWidth;
        _maxDragExtent = _maxSliderWidth * 0.85;
      });
    });

    _animationController2.addListener(() {
      setState(() {});
    });

    _animationController.addListener(() {
      if (_animationController.isCompleted) {
        print("yes forward2");
        _animationController2.forward();
      }
    });
  }

  @override
  void dispose() {
    _keyboardTextController.dispose();
    _animationController.dispose();
    _animationController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
          child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Column(
                  children: [
                    Expanded(
                      child: _buildMainContent(),
                    ),
                    const SizedBox(height: 40),
                    _buildSliderWidget()
                  ],
                );
              }),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        if (_animationController.isAnimating ||
            _animationController.isCompleted)
          SlideTransition(
            position: _amountSlideAnimation,
            child: Text(
              '\u20A6${_keyboardTextController.text}',
              style: Theme.of(context)
                  .textTheme
                  .displayLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        if (_animationController.isCompleted &&
            _animationController2.isCompleted)
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: _AnimatedProgressBar(
                    onCompleted: () {
                      print("called!!!!!!");
                      isProgressCompleted = true;
                      setState(() {});
                    },
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: isProgressCompleted ? 1 : 0,
                  curve: Curves.easeOut,
                  child: const Icon(
                    Icons.check,
                    size: 70,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        if (!_animationController.isAnimating &&
            !_animationController.isCompleted)
          Expanded(
              child: PinInputWidget(
            controller: _keyboardTextController,
          )),
      ],
    );
  }

  Widget _buildSliderWidget() {
    return Container(
      key: _sliderKey,
      height: _containerHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(50),
      ),
      clipBehavior: Clip.none,
      child: Stack(
        children: [
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchOutCurve: Curves.easeIn,
              child: _maxSliderWidth == _xDragOffet
                  ? Text(
                      'Sending...',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey,
                          ),
                    )
                  : const LoadingAnimation(),
            ),
          ),
          Positioned.fill(
            child: _buildSendButton(),
          ),
          AnimatedPositioned(
            top: 0,
            bottom: 0,
            left: _xDragOffet,
            duration: isSliding
                ? const Duration(milliseconds: 50)
                : const Duration(milliseconds: 250),
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                // _xDragOffet +=
                //     details.delta.dx.clamp(0, maxSliderWidth);
                if (_xDragOffet == _maxSliderWidth) return;
                _xDragOffet =
                    (_xDragOffet + details.delta.dx).clamp(0, _maxSliderWidth);
                isSliding = true;
                setState(() {});
              },
              onHorizontalDragEnd: (details) {
                if (_xDragOffet <= _maxDragExtent) {
                  _xDragOffet = 0;
                } else {
                  _xDragOffet = _maxSliderWidth;
                  _animationController.forward();
                }
                isSliding = false;
                setState(() {});
              },
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _logoSlideAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: PaymetIconWidget(
                      isActive: _xDragOffet == _maxSliderWidth,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: isProgressCompleted ? 1 : 0,
      curve: Curves.easeOut,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Center(
          child: Text(
            'SENT',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.black,
                ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedProgressBar extends StatefulWidget {
  const _AnimatedProgressBar({
    super.key,
    this.onCompleted,
  });

  final VoidCallback? onCompleted;

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
      duration: const Duration(seconds: 3),
    );

    _animationController.forward();

    _animationController.addListener(() {
      if (_animationController.isCompleted) {
        widget.onCompleted?.call();
      }
    });
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
    canvas.drawCircle(center, 80, innerCirclePaint);
    canvas.drawArc(
      Rect.fromCenter(center: center, width: 160, height: 160),
      0.radians,
      progress,
      false,
      progressCirclePaint,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) => true;
}
