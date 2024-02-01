import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SwipeToPayPage extends StatefulWidget {
  const SwipeToPayPage({super.key});

  static PageRoute route() =>
      MaterialPageRoute(builder: (_) => const SwipeToPayPage());

  @override
  State<SwipeToPayPage> createState() => _SwipeToPayPageState();
}

class _SwipeToPayPageState extends State<SwipeToPayPage> {
  late final TextEditingController keyboardText;
  @override
  void initState() {
    super.initState();
    keyboardText = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Enter Amount'),
              TextField(
                controller: keyboardText,
                showCursor: false,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
              ),
              const Spacer(),
              _Keypad(
                onKeyPressed: (value) {
                  if (value == 'x') {
                    keyboardText.text = keyboardText.text.removeLastChar;
                  } else if (value == '.') {
                    keyboardText.text +=
                        !keyboardText.text.contains('.') ? value : "";
                  } else {
                    keyboardText.text += value;
                  }
                },
              ),
              const Spacer(),
              const PaymentSlider(),
            ],
          ),
        ),
      ),
    );
  }
}

class PaymentSlider extends StatefulWidget {
  const PaymentSlider({
    super.key,
  });

  @override
  State<PaymentSlider> createState() => _PaymentSliderState();
}

class _PaymentSliderState extends State<PaymentSlider> {
  double _xDragOffet = 0;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Container(
      height: 70,
      width: size.width,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Stack(
        children: [
          const Center(
            child: LoadingAnimation(),
          ),
          AnimatedPositioned(
            top: 0,
            bottom: 0,
            left: _xDragOffet,
            duration: const Duration(milliseconds: 0),
            child: GestureDetector(
              onHorizontalDragStart: (details) {
                _xDragOffet = details.globalPosition.dx;
                setState(() {});
              },
              onHorizontalDragUpdate: (details) {
                print(details.localPosition.dx);
                // if (xDragOffet < size.width) {
                //   xDragOffet = details.globalPosition.dx;
                // }
                _xDragOffet = details.globalPosition.dx.clamp(0, 300);
                setState(() {});
                print(size.width);
              },
              onHorizontalDragEnd: (details) {
                if (_xDragOffet <= 300 * 0.7) {
                  _xDragOffet = 0;
                } else {
                  _xDragOffet = 300;
                }
                setState(() {});
              },
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 5),
                ),
                alignment: Alignment.center,
                child: Text(
                  '₦',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoadingAnimation extends StatefulWidget {
  const LoadingAnimation({super.key, this.count = 3});

  final int count;

  @override
  State<LoadingAnimation> createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<LoadingAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _animationController.forward();
    _animationController.repeat();
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
        return Wrap(
          spacing: 3,
          children: List.generate(widget.count, (index) {
            final opacity = CurvedAnimation(
              parent: _animationController,
              curve: Interval((index / widget.count), 1.0),
            );
            return FadeTransition(
              opacity: opacity,
              child: Text(
                ">",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({
    super.key,
    this.onKeyPressed,
  });

  final ValueSetter<String>? onKeyPressed;

  @override
  Widget build(BuildContext context) {
    const keys = '123456789.0x';
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
      ),
      itemBuilder: (context, index) {
        final key = keys[index];
        return ClipRRect(
          child: Material(
            type: MaterialType.button,
            color: Colors.white10,
            shape: const CircleBorder(),
            child: InkWell(
              borderRadius: BorderRadius.circular(60),
              onTap: () {
                HapticFeedback.lightImpact();
                onKeyPressed?.call(key);
              },
              child: Align(
                child: key == 'x'
                    ? const Icon(Icons.backspace_outlined)
                    : Text(
                        key,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
              ),
            ),
          ),
        );
      },
      itemCount: keys.length,
    );
  }
}

extension KeypadEx on String {
  String get removeLastChar => isNotEmpty ? substring(0, length - 1) : "";
}
