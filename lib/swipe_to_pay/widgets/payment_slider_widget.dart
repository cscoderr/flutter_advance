import 'package:animation_playground/swipe_to_pay/swipe_to_pay.dart';
import 'package:flutter/material.dart';

class PaymentSliderWidget extends StatefulWidget {
  const PaymentSliderWidget({
    super.key,
    this.onComplete,
    required this.containerHeight,
    required this.maxSliderWidth,
    required this.maxDragExtent,
  });

  final double containerHeight;
  final double maxSliderWidth;
  final double maxDragExtent;
  final void Function(bool)? onComplete;

  @override
  State<PaymentSliderWidget> createState() => _PaymentSliderWidgetState();
}

class _PaymentSliderWidgetState extends State<PaymentSliderWidget> {
  double _xDragOffet = 0.0;
  bool isSliding = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.containerHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(50),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchOutCurve: Curves.easeIn,
              child: widget.maxSliderWidth == _xDragOffet
                  ? Text(
                      'Sending...',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey,
                          ),
                    )
                  : const LoadingAnimation(),
            ),
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
                if (_xDragOffet == widget.maxSliderWidth) return;
                _xDragOffet = (_xDragOffet + details.delta.dx)
                    .clamp(0, widget.maxSliderWidth);
                isSliding = true;
                setState(() {});
              },
              onHorizontalDragEnd: (details) {
                if (_xDragOffet <= widget.maxDragExtent) {
                  _xDragOffet = 0;
                } else {
                  _xDragOffet = widget.maxSliderWidth;
                  widget.onComplete?.call(_xDragOffet == widget.maxSliderWidth);
                }
                isSliding = false;
                setState(() {});
              },
              child: PaymetIconWidget(
                isActive: _xDragOffet == widget.maxSliderWidth,
              ),
            ),
          ),
          if (1 == 2)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _xDragOffet == widget.maxSliderWidth ? 1 : 0,
              child: Container(
                width: double.infinity,
                height: widget.containerHeight,
                decoration: const BoxDecoration(
                  color: Colors.white,
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
            )
        ],
      ),
    );
  }
}
