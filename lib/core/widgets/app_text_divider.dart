import 'package:flutter/material.dart';

class AppTextDivider extends StatelessWidget {
  const AppTextDivider({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          const SizedBox(width: 5),
          Text(
            text,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}
