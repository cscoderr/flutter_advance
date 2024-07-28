import 'dart:math';

import 'package:animation_playground/gen/assets.gen.dart';
import 'package:flutter/material.dart';

class TarotScrollPage extends StatefulWidget {
  const TarotScrollPage({super.key});

  static PageRoute route() =>
      MaterialPageRoute(builder: (context) => const TarotScrollPage());

  @override
  State<TarotScrollPage> createState() => _TarotScrollPageState();
}

class _TarotScrollPageState extends State<TarotScrollPage>
    with SingleTickerProviderStateMixin {
  late FixedExtentScrollController _scrollController;
  late AnimationController _animationController;

  final _totalCard = 100;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = FixedExtentScrollController(initialItem: _totalCard);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        50 * 100,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.ease,
      );
      _animationController.forward();
    });
    _animationController.addListener(
      () {
        setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blueGrey,
        appBar: AppBar(
          title: const Text('Tarot Scroll'),
        ),
        body: OverflowBox(
          alignment: Alignment.bottomCenter,
          maxHeight: MediaQuery.sizeOf(context).height * 0.3,
          maxWidth: MediaQuery.sizeOf(context).width,
          child: RotatedBox(
            quarterTurns: 3,
            child: ListWheelScrollView(
              controller: _scrollController,
              physics: const FixedExtentScrollPhysics(),
              itemExtent: 70,
              squeeze: 3.5 - _animationController.value,
              renderChildrenOutsideViewport: true,
              offAxisFraction: 4,
              perspective: 0.001,
              clipBehavior: Clip.none,
              onSelectedItemChanged: (value) {
                setState(() {
                  _currentIndex = value;
                });
              },
              children: List.generate(
                _totalCard,
                (index) {
                  return GestureDetector(
                    behavior: HitTestBehavior.deferToChild,
                    onTap: () {
                      // print('tap');
                      // final pageRoute = PageRouteBuilder(
                      //   pageBuilder: (context, animation, secondaryAnimation) {
                      //     return TarotDetailsPage(index: index);
                      //   },
                      // );
                      // Navigator.of(context).push(pageRoute);
                    },
                    child: Hero(
                      tag: ValueKey('_tarot_image_tag_$index'),
                      child: AnimatedTarotCard(
                        key: ValueKey('_animated_tarot_card_$index'),
                        index: _currentIndex,
                        applyAnimation: index == _currentIndex.floor(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ));
  }
}

class AnimatedTarotCard extends StatefulWidget {
  const AnimatedTarotCard({
    super.key,
    required this.index,
    this.applyAnimation = false,
  });
  final int index;
  final bool applyAnimation;

  @override
  State<AnimatedTarotCard> createState() => _AnimatedTarotCardState();
}

class _AnimatedTarotCardState extends State<AnimatedTarotCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      // reverseDuration: const Duration(milliseconds: 100),
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 55.0 + (widget.index / 50),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.applyAnimation) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AnimatedTarotCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index < 0 || widget.index > 99) return;
    if (widget.applyAnimation) {
      _animationController.forward();
    } else {
      _animationController.reverse();
      // WidgetsBinding.instance.addPostFrameCallback(
      //     (timeStamp) => Future.delayed(const Duration(milliseconds: 100), () {

      //         }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_animation.value, 0),
            child: RotatedBox(
              quarterTurns: 1,
              child: Container(
                width: 70,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  image: DecorationImage(
                    image: ResizeImage(
                      Assets.images.img.provider(),
                      width: 210,
                      height: 300,
                    ),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(color: Colors.grey[300]!, width: 5),
                ),
              ),
            ),
          );
        });
  }
}

class TarotDetailsPage extends StatelessWidget {
  const TarotDetailsPage({
    super.key,
    required this.index,
  });

  final int index;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BackButton(),
              const SizedBox(height: 10),
              Hero(
                tag: ValueKey('_tarot_image_tag_$index'),
                flightShuttleBuilder: (flightContext, animation,
                    flightDirection, fromHeroContext, toHeroContext) {
                  final newAnimation =
                      Tween(begin: 1, end: 0.0).animate(animation);
                  return Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateZ(-pi * newAnimation.value),
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 70,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        image: DecorationImage(
                          image: Assets.images.tarotBack.provider(),
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(color: Colors.white, width: 5),
                      ),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: MediaQuery.sizeOf(context).height * 0.7,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    image: DecorationImage(
                      image: Assets.images.tarotFront.provider(),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
