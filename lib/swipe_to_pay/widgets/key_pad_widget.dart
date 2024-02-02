import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeypadWidget extends StatelessWidget {
  const KeypadWidget({
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
        mainAxisExtent: 80,
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
