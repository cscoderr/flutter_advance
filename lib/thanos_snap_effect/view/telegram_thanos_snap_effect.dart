import 'dart:math' as math;

import 'package:animation_playground/core/core.dart';
import 'package:animation_playground/gen/assets.gen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

class Particle {
  Particle({
    required this.x,
    required this.y,
    required this.color,
  });

  double x;
  double y;
  final Color color;
}

extension ParticleEx on Particle {
  Particle update() {
    final random = math.Random();
    x += random.nextDouble();
    y += random.nextDouble() - 2;

    return Particle(x: x, y: y, color: color);
  }
}

class TelegramThanosSnapEffectPage extends StatefulWidget {
  const TelegramThanosSnapEffectPage({super.key});

  static PageRoute route() =>
      MaterialPageRoute(builder: (_) => const TelegramThanosSnapEffectPage());

  @override
  State<TelegramThanosSnapEffectPage> createState() =>
      _TelegramThanosSnapEffectPageState();
}

class _TelegramThanosSnapEffectPageState
    extends State<TelegramThanosSnapEffectPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  final List<Particle> _particles = [];
  late AnimationController _animationController;
  Size? _imageSize;
  late Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _ticker = Ticker(
      (elapsed) {
        if (_particles.isNotEmpty) {
          _randomizeParticle();
        }
      },
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _randomizeParticle() {
    final particles = List.from(_particles);
    _particles.clear();
    setState(() {});
    for (Particle particle in particles) {
      _particles.add(particle.update());
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Stack(
            children: [
              GestureDetector(
                onTap: _handleSnap,
                child: AnimatedOpacity(
                  opacity: _particles.isNotEmpty ? 0 : 1,
                  duration: const Duration(milliseconds: 1000),
                  child: RepaintBoundary(
                    key: _globalKey,
                    child: Assets.images.img.image(),
                  ),
                ),
              ),
              if (_particles.isNotEmpty && _imageSize != null)
                Positioned.fill(
                  child: CustomPaint(
                    painter:
                        ThanosSnapPainter(_particles, _animationController),
                    child: SizedBox(
                      height: _imageSize?.height.toDouble(),
                      width: _imageSize?.width.toDouble(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSnap() async {
    final imageByte = await _captureWidgetAsImageByte();
    for (var y = 0; y < _imageSize!.height; y += 5) {
      for (var x = 0; x < _imageSize!.width; x += 5) {
        final index = (y * _imageSize!.width.toInt() + x) * 4;
        final red = imageByte[index];
        final green = imageByte[index + 1];
        final blue = imageByte[index + 2];
        final alpha = imageByte[index + 3];
        final color = Color.fromARGB(alpha, red, green, blue);
        _particles.add(
          Particle(x: x.toDouble(), y: y.toDouble(), color: color),
        );
      }
    }
    _animationController.forward();
    _ticker.start();

    // const chunkSize = 50;

    // final chunks = _particleIntoChunk(_particles, chunkSize);
    // _particles.clear();
    // setState(() {});
    // for (var chunk in chunks) {
    //   _particles.addAll(chunk);
    // }
  }

  List<List<Particle>> _particleIntoChunk(
      List<Particle> particles, int chunkSize) {
    final chunks = <List<Particle>>[];
    for (var i = 0; i < particles.length; i += chunkSize) {
      final end = chunkSize + i;
      final chunk = particles.sublist(i, end <= particles.length ? end : null);
      chunks.add(chunk);
    }
    return chunks;
  }

  Future<Uint8List> _captureWidgetAsImageByte() async {
    final boundary =
        _globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
    setState(() {
      _imageSize = boundary.size;
    });
    var imgage = await boundary.toImage();
    var byteData = await imgage.toByteData();
    var imageByte = byteData!.buffer.asUint8List();
    return imageByte;
  }
}

class ThanosSnapPainter extends CustomPainter {
  ThanosSnapPainter(this.particles, this.animationController)
      : super(repaint: animationController);
  final List<Particle> particles;
  final AnimationController animationController;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < particles.length; i++) {
      double start = (i / particles.length) * (1 - 0.6);
      double end = math.min(start + 0.6, 1);
      final animation = Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(64, 32) + const Offset(-64, -32),
      ).animate(
        CurvedAnimation(
          parent: animationController,
          curve: Interval(
            start,
            end,
            curve: Curves.easeOut,
          ),
        ),
      );

      canvas.save();
      final polar = toPolar(size.center(Offset.zero), i, particles.length, 1);
      // canvas.translate(
      //   polar.dx,
      //   polar.dy,
      // );

      final particle = particles[i];

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        2,
        Paint()..color = particle.color,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ThanosSnapPainter oldDelegate) => true;
}
