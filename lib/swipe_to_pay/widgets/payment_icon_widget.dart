import 'package:flutter/material.dart';

class PaymetIconWidget extends StatelessWidget {
  const PaymetIconWidget({
    super.key,
    required this.iconKey,
    this.isActive = false,
  });

  final bool isActive;
  final GlobalKey iconKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: iconKey,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border:
            Border.all(color: isActive ? Colors.green : Colors.white, width: 5),
      ),
      alignment: Alignment.center,
      child: Text(
        '\u20A6',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: isActive ? Colors.green : Colors.white,
            ),
      ),
    );
  }
}
