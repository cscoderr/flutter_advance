import 'package:flutter/material.dart';

class SliderTextWidget extends StatelessWidget {
  const SliderTextWidget({
    super.key,
    required this.text,
    this.hasSign = true,
  });
  final String text;
  final bool hasSign;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '\u20A6',
          style: Theme.of(context)
              .textTheme
              .displayMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        ...List.generate(
          text.length,
          (index) => SliderText(
            value: int.tryParse(text[index]) ?? 0,
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
      _scrollController.animateTo(
        (_maxScrollHeight * widget.value).toDouble(),
        duration: const Duration(milliseconds: 500),
        curve: Curves.elasticOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
              style: Theme.of(context)
                  .textTheme
                  .displayMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}
