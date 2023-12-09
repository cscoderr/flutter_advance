import 'package:animation_playground/rainbow_sticks_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

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

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      upperBound: 1.1,
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        const springDescription = SpringDescription(
          mass: 0.8,
          stiffness: 180.0,
          damping: 20.0,
        );
        final simulation = SpringSimulation(springDescription,
            _animationController.value, 0.05, _animationController.velocity);
        _animationController.animateWith(simulation);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _openMenu() {
    _animationController.reset();

    const springDescription = SpringDescription(
      mass: 0.8,
      stiffness: 180.0,
      damping: 20.0,
    );
    final simulation = SpringSimulation(
        springDescription, 0, 1, _animationController.velocity);
    _animationController.animateWith(simulation);
    setState(() {
      isOpen = true;
    });
  }

  void _closeMenu(Color color) {
    _animationController.reverse();

    setState(() {
      selectedColor = color;
    });
    Future.delayed(const Duration(milliseconds: 250), () {
      setState(() {
        _animationController.reset();
        isOpen = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Stack(
              children: [
                GestureDetector(
                  onTap: () => _closeMenu(selectedColor),
                  child: AnimatedContainer(
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
                ),
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: _animationController
                            .drive(Tween(
                                begin: size.width * 0.4, end: size.width * 0.9))
                            .value,
                        height: MediaQuery.of(context).size.width * 0.9,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white70,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black54,
                              blurRadius: isOpen ? 30 : 10,
                              offset: Offset(
                                0,
                                isOpen ? 10 : 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...colors.asMap().entries.map((e) {
                        final angle = e.key * (360 / colors.length);

                        return GestureDetector(
                          onTap: () {
                            _closeMenu(e.value);
                          },
                          child: Transform.rotate(
                            angle: _animationController
                                .drive(Tween(begin: 0.0, end: angle.radians))
                                .value,
                            child: Transform.translate(
                              offset: Offset(
                                0.0,
                                _animationController
                                    .drive(Tween(
                                        begin: 0.0, end: -size.width * 0.2))
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
                                margin: const EdgeInsets.all(100),
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
                                      color: _animationController
                                          .drive(ColorTween(
                                              begin: Colors.transparent,
                                              end: Colors.black
                                                  .withOpacity(0.4)))
                                          .value!,
                                      // isOpen
                                      //     ? Colors.black.withOpacity(0.4)
                                      //     : Colors.transparent,
                                      blurRadius: 5,
                                      offset: const Offset(0, 12),
                                    )
                                  ],
                                  borderRadius: BorderRadius.circular(
                                      ((size.width * 0.40) / 2) - 10),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      if (!isOpen)
                        GestureDetector(
                          onTap: _openMenu,
                          child: Container(
                            width: size.width * 0.3,
                            height: size.width * 0.3,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: selectedColor,
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              ],
            );
          }),
    );
  }
}
