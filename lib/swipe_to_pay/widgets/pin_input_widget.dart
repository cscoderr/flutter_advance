import 'package:animation_playground/swipe_to_pay/swipe_to_pay.dart';
import 'package:flutter/material.dart';

class PinInputWidget extends StatelessWidget {
  const PinInputWidget({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter Amount',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              TextField(
                controller: controller,
                showCursor: false,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
              ),
            ],
          ),
        ),
        KeypadWidget(
          onKeyPressed: (value) {
            if (value == 'x') {
              controller.text = controller.text.removeLastChar;
            } else if (value == '.') {
              controller.text += !controller.text.contains('.') ? value : "";
            } else {
              controller.text += value;
            }
          },
        ),
      ],
    );
  }
}
