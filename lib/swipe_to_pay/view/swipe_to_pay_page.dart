import 'package:animation_playground/swipe_to_pay/swipe_to_pay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';

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
  final _iconKey = GlobalKey();
  double _sliderWidth = 0.0;
  double _maxSliderWidth = 0.0;
  double _minSliderWidth = 0.0;
  final double _containerHeight = 80;
  double _maxDragExtent = 0.0;
  double _xDragOffet = 0.0;
  bool isSliding = false;
  bool _hasReachSlideThreshold = false;
  bool isProgressCompleted = false;

  late final TextEditingController _pinController;
  late final AnimationController _animationController;
  late final AnimationController _animationController2;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _logoSlideAnimation;
  late final Animation<Offset> _amountSlideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pinController = TextEditingController();
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
        Tween(begin: Offset.zero, end: const Offset(-2.1, -4.5)).animate(
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
      final iconRenderBox =
          _iconKey.currentContext?.findRenderObject() as RenderBox?;
      setState(() {
        _sliderWidth = renderBox?.size.width ?? 0.0;
        _minSliderWidth = iconRenderBox?.size.width ?? 50;
        _maxSliderWidth = _sliderWidth - _minSliderWidth;
        _maxDragExtent = _maxSliderWidth * 0.85;
      });
    });

    _animationController.addStatusListener(_onStatusChanged);
  }

  void _onStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _animationController2.forward();
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
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
              animation: Listenable.merge([
                _animationController,
                _animationController2,
                _pinController,
              ]),
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
    final formattedText = NumberFormat.currency(symbol: '', decimalDigits: 0)
        .format(int.tryParse(_pinController.text) ?? 0)
        .toString();
    return Column(
      children: [
        if (_hasReachSlideThreshold)
          SlideTransition(
            position: _amountSlideAnimation,
            child: Text(
              '\u20A6$formattedText',
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
                  child: AnimatedCircularProgressBar(
                    onCompleted: () {
                      setState(() {
                        isProgressCompleted = true;
                      });
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
        if (!_hasReachSlideThreshold)
          Expanded(
              child: PinInputWidget(
            controller: _pinController,
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
                  _hasReachSlideThreshold = false;
                  _xDragOffet = 0;
                } else {
                  _xDragOffet = _maxSliderWidth;
                  _hasReachSlideThreshold = true;
                  Future.delayed(
                    const Duration(milliseconds: 500),
                    () => _animationController.forward(),
                  );
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
                      iconKey: _iconKey,
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
