import 'dart:math';

import 'package:flutter/material.dart';
import 'package:interpolate_animated/interpolate_animated.dart';

class OnboardingAnimationPage extends StatefulWidget {
  const OnboardingAnimationPage({super.key});

  @override
  State<OnboardingAnimationPage> createState() =>
      _OnboardingAnimationPageState();
}

class _OnboardingAnimationPageState extends State<OnboardingAnimationPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late Animation _scaleAnimation;

  final double _animation = 0.0;
  int _currentIndex = 0;
  final _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween(begin: 1.0, end: 0.8).animate(CurvedAnimation(
        parent: _animationController, curve: const Interval(0.5, 1.0)));

    _animationController.addListener(() {
      setState(() {
        // _animation = _animationController.value;
        if (_animationController.value.toStringAsFixed(1).endsWith('.6')) {
          _pageController.jumpToPage(
            _currentIndex + 1,
          );
        }
      });
    });

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_currentIndex < data.length - 1) {
          setState(() {
            _currentIndex++;
          });
          _animationController.reset();
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  final data = <Onboarding>[
    Onboarding(
      title: "Let's Get Started!",
      content:
          "Buckle up, we're about to embark on a thrilling digital journey with App. Swipe, tap, and let's dive into the awesomeness!",
      imagePath: 'assets/images/feature1.png',
      backgroundColor: const Color(0xFFFFFFFF),
      color: const Color(0xFF6BF6FF),
    ),
    Onboarding(
      title: 'Stay in the Loop, Have a Scoop',
      content:
          'No more FOMO! Get real-time updates and stay in the loop, all while sipping your morning coffee.',
      imagePath: 'assets/images/feature2.png',
      backgroundColor: const Color(0xFF6BF6FF),
      color: const Color(0xFFFFD952),
    ),
    Onboarding(
      title: 'Discover the Magic',
      content:
          "It's like opening a treasure chest of features! Customize your experience, discover hidden gems, and get ready to be amazed.",
      imagePath: 'assets/images/feature3.png',
      backgroundColor: const Color(0xFFFFD952),
      color: const Color(0xffffffff),
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final backgroundColor = data[_currentIndex].backgroundColor;
          final nextIndex = _currentIndex + 1;
          final nextBackgroundColor = nextIndex < data.length
              ? data[nextIndex].backgroundColor
              : backgroundColor;
          return ColoredBox(
            color: ColorTween(begin: backgroundColor, end: nextBackgroundColor)
                .animate(CurvedAnimation(
                    parent: _animationController,
                    curve: const Interval(0.4, 1)))
                .value!,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                print(index);
                // setState(() {
                //   _currentIndex = index;
                // });
              },
              itemBuilder: (context, index) {
                final item = data[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    children: [
                      Expanded(
                        child: Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _AnimatedImage(imageUrl: item.imagePath),
                                const SizedBox(height: 40),
                                Text(
                                  item.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: Colors.black,
                                      ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  item.content,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Colors.black,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.002)
                            ..rotateY(interpolate(
                              _animationController.value,
                              inputRange: [
                                _animation,
                                _animation + 0.5,
                                _animation + 0.99,
                                _animation + 1,
                              ],
                              outputRange: [0, (pi / 2), pi, 0],
                            )),

                          // ..rotateY(
                          //   interpolate(
                          //     _animationController.value,
                          //     inputRange: [
                          //       0,
                          //       0.5,
                          //       0.99,
                          //       1,
                          //     ],
                          //     outputRange: [
                          //       0,
                          //       -(90 * pi) / 180,
                          //       -(180 * pi) / 180,
                          //       0,
                          //     ],
                          //     // extrapolate: Extrapolate.extend,
                          //   ),
                          // )
                          // ..scale(1 - _animation * 0.6),
                          // ..translate(_animation * 30.0),

                          // ..translate(
                          //   interpolate(
                          //     _animationController.value,
                          //     inputRange: [
                          //       _animation,
                          //       _animation + 0.5,
                          //       _animation + 1,
                          //     ],
                          //     outputRange: [
                          //       0,
                          //       -30,
                          //       0,
                          //     ],
                          //     // extrapolate: Extrapolate.extend,
                          //   ),
                          // )
                          // ..scale(
                          // interpolate(
                          //   _animationController.value,
                          //   inputRange: [
                          //     _animation,
                          //     _animation + 0.5,
                          //     _animation + 1,
                          //   ],
                          //   outputRange: [
                          //     1,
                          //     8,
                          //     0,
                          //   ],
                          //   // extrapolate: Extrapolate.extend,
                          // ),
                          // ),
                          child: Transform.translate(
                            offset: Offset(_animationController.value * -60, 0),
                            child: Transform.scale(
                              scale: interpolate(
                                _animationController.value,
                                inputRange: [
                                  _animation + 0,
                                  _animation + 0.5,
                                  _animation + 1,
                                ],
                                outputRange: [
                                  1,
                                  12,
                                  1,
                                ],
                              ),
                              child: AnimatedContainer(
                                height: 80,
                                width: 80,
                                duration: const Duration(milliseconds: 500),
                                decoration: BoxDecoration(
                                  color: ColorTween(
                                    begin: nextBackgroundColor,
                                    end: item.color,
                                  )
                                      .animate(CurvedAnimation(
                                          parent: _animationController,
                                          curve: const Interval(0.95, 1)))
                                      .value!,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: Image.asset(
                                      'assets/icons/angle-right.png'),
                                  onPressed: () {
                                    _animationController.reset();
                                    _animationController.forward();
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              itemCount: data.length,
            ),
          );
        },
      ),
    );
  }
}

class Onboarding {
  final String title;
  final String content;
  final String imagePath;
  final Color backgroundColor;
  final Color color;
  Onboarding({
    required this.title,
    required this.content,
    required this.imagePath,
    required this.backgroundColor,
    required this.color,
  });
}

class _AnimatedImage extends StatefulWidget {
  const _AnimatedImage({
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  State<_AnimatedImage> createState() => __AnimatedImageState();
}

class __AnimatedImageState extends State<_AnimatedImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )
      ..forward()
      ..repeat(reverse: true);
    _bounceAnimation = TweenSequence([
      TweenSequenceItem(
          tween: Tween(begin: 10.0, end: 5.0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 10),
      TweenSequenceItem(
          tween: Tween(begin: 5.0, end: 0.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 8),
    ]).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) => Transform(
        transform: Matrix4.identity()..translate(0.0, _bounceAnimation.value),
        child: Image.asset(widget.imageUrl),
      ),
    );
  }
}
