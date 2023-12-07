import 'package:animation_playground/core/core.dart';
import 'package:flutter/material.dart';

class PetalMenu extends StatefulWidget {
  const PetalMenu({super.key});

  @override
  State<PetalMenu> createState() => _PetalMenuState();
}

class _PetalMenuState extends State<PetalMenu>
    with SingleTickerProviderStateMixin {
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
  Color selectedColor = Colors.red;
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));
    _animation = Tween(begin: 0.0, end: (360 / colors.length)).animate(
      CurvedAnimation(
          parent: _animationController, curve: const Interval(0, 0.5)),
    );

    _animationController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final center = size.center(Offset.zero);
    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
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
            children: [
              // Positioned(
              //   child: AnimatedContainer(
              //     width: isOpen
              //         ? MediaQuery.of(context).size.width * 0.9
              //         : MediaQuery.of(context).size.width * 0.4,
              //     height: MediaQuery.of(context).size.width * 0.9,
              //     decoration: BoxDecoration(
              //       shape: BoxShape.circle,
              //       color: Colors.black12,
              //       boxShadow: [
              //         BoxShadow(
              //           color: isOpen
              //               ? Colors.black.withOpacity(0.4)
              //               : Colors.transparent,
              //           blurRadius: isOpen ? 30 : 10,
              //           offset: Offset(
              //             0,
              //             isOpen ? 10 : 0,
              //           ),
              //         ),
              //       ],
              //     ),
              //     duration: const Duration(milliseconds: 300),
              //   ),
              // ),
              ...colors.asMap().entries.map((e) {
                final theta = e.key * colors.length.stepsInAngle;

                final offset =
                    toPolar(size.center(Offset.zero), e.key, colors.length, 75);

                double startValue = (e.key / colors.length);
                return Positioned(
                  top: offset.dy,
                  left: offset.dx,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isOpen = !isOpen;
                        selectedColor = e.value;
                      });
                    },
                    child: Transform.rotate(
                      angle: isOpen ? (e.key * (360 / colors.length)) : 0,
                      child: AnimatedContainer(
                        height: isOpen ? size.width * 0.40 : size.width * 0.25,
                        width: size.width * 0.25,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.bounceInOut,
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
                          borderRadius: BorderRadius.circular(isOpen
                              ? ((size.width * 0.40) / 2) - 10
                              : (size.width * 0.40) / 2),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
              if (!isOpen)
                Positioned(
                  child: GestureDetector(
                    onTap: () {
                      _animationController.reset();
                      _animationController.forward();
                      setState(() {
                        isOpen = !isOpen;
                      });
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: MediaQuery.of(context).size.width * 0.3,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selectedColor,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
