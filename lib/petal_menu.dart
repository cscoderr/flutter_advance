import 'package:animation_playground/core/core.dart';
import 'package:flutter/material.dart';

class PetalMenu extends StatefulWidget {
  const PetalMenu({super.key});

  @override
  State<PetalMenu> createState() => _PetalMenuState();
}

class _PetalMenuState extends State<PetalMenu> with TickerProviderStateMixin {
  final colors = [
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.cyan,
    Colors.blue,
    Colors.purple,
    Colors.pink,
    Colors.red,
  ];
  bool isOpen = false;
  Color selectedColor = Colors.purple;
  late final AnimationController _animationController;
  late final AnimationController _animationController2;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _animationController2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _animationController.addListener(() {
      setState(() {});
    });

    _animationController2.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250 ~/ 2),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                selectedColor.withOpacity(0.2),
                selectedColor.withOpacity(0.5),
                selectedColor
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Center(
          child: Stack(
            alignment: AlignmentDirectional.center,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                child: Container(
                  width: _animationController
                      .drive(
                          Tween(begin: size.width * 0.4, end: size.width * 0.9))
                      .value,
                  // ? MediaQuery.of(context).size.width * 0.9
                  // : MediaQuery.of(context).size.width * 0.4,
                  height: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black12,
                    boxShadow: [
                      BoxShadow(
                        color: _animationController
                            .drive(ColorTween(
                                begin: Colors.transparent,
                                end: Colors.black.withOpacity(0.4)))
                            .value!,
                        // isOpen
                        //     ? Colors.black.withOpacity(0.4)
                        //     : Colors.transparent,
                        blurRadius: isOpen ? 30 : 10,
                        offset: Offset(
                          0,
                          isOpen ? 10 : 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ...colors.asMap().entries.map((e) {
                final angle = e.key * (360 / colors.length);

                return GestureDetector(
                  onTap: () {
                    _animationController.reverse();
                    setState(() {
                      selectedColor = e.value;
                    });
                    Future.delayed(const Duration(milliseconds: 250), () {
                      setState(() {
                        _animationController.reset();
                        isOpen = false;
                      });
                    });
                  },
                  child: Transform.rotate(
                    angle: isOpen
                        ? _animationController
                            .drive(Tween(begin: 0.0, end: angle.radians))
                            .value
                        : 0,
                    child: Transform(
                      transform: Matrix4.identity()
                        ..translate(
                          Tween(begin: 0.0, end: 5.0)
                              .animate(CurvedAnimation(
                                  parent: _animationController2,
                                  curve: const Interval(0.8, 1,
                                      curve: Curves.elasticInOut)))
                              .value,
                          _animationController
                              .drive(Tween(begin: 0.0, end: -size.width * 0.2))
                              .value,
                        ),
                      child: Container(
                        height: _animationController
                            .drive(Tween(
                                begin: size.width * 0.25,
                                end: size.width * 0.40))
                            .value,
                        //(isOpen ? size.width * 0.40 : size.width * 0.25),
                        width: size.width * 0.25,
                        decoration: BoxDecoration(
                          color: e.value,
                          gradient: LinearGradient(
                            colors: [
                              colors[e.key],
                              colors[e.key],
                              colors[e.key].withOpacity(0.7)
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          boxShadow: [
                            BoxShadow(
                                color: isOpen
                                    ? Colors.black.withOpacity(0.4)
                                    : Colors.transparent,
                                blurRadius: 5,
                                offset: const Offset(0, 12))
                          ],
                          borderRadius: BorderRadius.circular(
                              ((size.width * 0.40) / 2) - 10),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250 ~/ 2),
                child: !isOpen
                    ? GestureDetector(
                        onTap: () {
                          _animationController.reset();
                          _animationController.forward();

                          _animationController2.reset();
                          _animationController2
                            ..forward()
                            ..reverse();
                          setState(() {
                            isOpen = true;
                          });
                          Future.delayed(const Duration(milliseconds: 1000),
                              () {
                            _animationController2.reset();
                          });
                        },
                        child: Container(
                          width: size.width * 0.3,
                          height: size.width * 0.3,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selectedColor,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
