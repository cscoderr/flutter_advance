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
        _Keypad(
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
                        style:
                            Theme.of(context).textTheme.displayMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
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
