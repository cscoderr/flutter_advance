import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class PaymetIconWidget extends StatelessWidget {
  const PaymetIconWidget({
    super.key,
    this.isActive = false,
  });

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border:
            Border.all(color: isActive ? Colors.green : Colors.white, width: 5),
      ),
      child: Icon(
        Iconsax.dollar_circle,
        size: 30,
        color: isActive ? Colors.green : Colors.white,
      ),
    );
  }
}
