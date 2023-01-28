import 'dart:ui';

import 'package:flutter/material.dart';

class AnimatedCardPage extends StatefulWidget {
  const AnimatedCardPage({Key? key}) : super(key: key);

  @override
  State<AnimatedCardPage> createState() => _AnimatedCardPageState();
}

class _AnimatedCardPageState extends State<AnimatedCardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isActive = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    var screenWidth = window.physicalSize.shortestSide;

    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween(begin: 1.0, end: 11.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          child: Column(
            children: const [
              AnimatedCard(
                activeColor: Color.fromRGBO(14, 165, 233, 1.0),
                inactiveColor: Color.fromRGBO(56, 189, 248, 1.0),
              ),
              SizedBox(height: 30),
              AnimatedCard(
                activeColor: Colors.orange,
                inactiveColor: Colors.orangeAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedCard extends StatefulWidget {
  const AnimatedCard({
    Key? key,
    required this.activeColor,
    this.inactiveColor,
  }) : super(key: key);

  final Color activeColor;
  final Color? inactiveColor;

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isActive = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    var screenWidth = window.physicalSize.shortestSide;

    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween(begin: 1.0, end: 11.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_controller.isCompleted) {
          _controller.reverse();
          setState(() {
            _isActive = false;
          });
        } else {
          _controller.forward();
          setState(() {
            _isActive = true;
          });
        }
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                          color: widget.activeColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (widget.inactiveColor ?? widget.activeColor)
                              .withOpacity(_opacityAnimation.value)),
                      child: const Icon(
                        Icons.message,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  'Perfect for learning how flutter impeller works, prototyping a new idea, or creating a demo to share online',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: _isActive ? Colors.white : Colors.black,
                      ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  'Learn More',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _isActive ? Colors.white : Colors.black,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
