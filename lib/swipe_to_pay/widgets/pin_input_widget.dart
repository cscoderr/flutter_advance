import 'package:animation_playground/swipe_to_pay/widgets/animated_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
              AnimatedText(
                text: controller.text,
                ondelete: () {
                  controller.text = controller.text.removeLastChar;
                },
              ),
            ],
          ),
        ),
        Keypad(
          controller: controller,
        ),
      ],
    );
  }
}

class Keypad extends StatelessWidget {
  const Keypad({
    super.key,
    this.onKeyPressed,
    required this.controller,
  });

  final ValueSetter<String>? onKeyPressed;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    const keys = '123456789.0x';
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
      ),
      itemBuilder: (context, index) {
        final key = keys[index];
        return key == '.'
            ? const SizedBox()
            : ClipRRect(
                child: Material(
                  type: MaterialType.button,
                  color: Colors.white10,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      if (key == 'x') {
                        controller.text = controller.text.contains('x')
                            ? controller.text
                            : controller.text.isNotEmpty
                                ? '${controller.text}x'
                                : '';
                      } else if (key == '.') {
                        controller.text +=
                            !controller.text.contains('.') ? key : "";
                      } else {
                        controller.text += key;
                      }
                      onKeyPressed?.call(key);
                    },
                    child: Align(child: _buildKeyWidget(context, key)),
                  ),
                ),
              );
      },
      itemCount: keys.length,
    );
  }

  Widget _buildKeyWidget(BuildContext context, String key) {
    if (key == 'x') {
      return const Icon(Icons.backspace_outlined);
    }

    if (key == '.') {
      return const SizedBox();
    }
    return Text(
      key,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
    );
  }
}

extension KeypadEx on String {
  String get removeLastChar => isNotEmpty ? substring(0, length - 2) : "";
}
