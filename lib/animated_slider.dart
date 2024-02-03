import 'package:flutter/material.dart';

class AnimatedSlider extends StatefulWidget {
  const AnimatedSlider({super.key});
  static PageRoute route() =>
      MaterialPageRoute(builder: (_) => const AnimatedSlider());

  @override
  State<AnimatedSlider> createState() => _AnimatedSliderState();
}

class _AnimatedSliderState extends State<AnimatedSlider> {
  double sliderValue = 100;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SliderTextWidget(
              text: sliderValue.toInt().toString(),
            ),
            const SizedBox(height: 30),
            Slider(
                value: sliderValue,
                max: 4500,
                onChanged: (value) {
                  setState(() {
                    sliderValue = value;
                  });
                }),
          ],
        ),
      ),
    );
  }
}

class SliderTextWidget extends StatelessWidget {
  const SliderTextWidget({
    super.key,
    required this.text,
  });
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '\u20A6',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        ...List.generate(
          text.length,
          (index) => SliderText(
            value: int.parse(text[index]),
          ),
        )
      ],
    );
  }
}

class SliderText extends StatefulWidget {
  const SliderText({
    super.key,
    required this.value,
  });

  final int value;

  @override
  State<SliderText> createState() => _SliderTextState();
}

class _SliderTextState extends State<SliderText> {
  late final ScrollController _scrollController;
  final double _maxScrollHeight = 52;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo((_maxScrollHeight * widget.value).toDouble());
    });
  }

  @override
  void didUpdateWidget(covariant SliderText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _scrollController.animateTo((_maxScrollHeight * widget.value).toDouble(),
          duration: const Duration(milliseconds: 500),
          curve: Curves.elasticOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _maxScrollHeight,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: List.generate(
            10,
            (index) => Text(
              '$index',
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
        ),
      ),
    );
  }
}
