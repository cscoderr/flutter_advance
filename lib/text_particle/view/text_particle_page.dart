import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:animation_playground/text_particle/text_particle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class TextParticlePage extends StatefulWidget {
  const TextParticlePage({super.key});

  static PageRoute route() =>
      MaterialPageRoute(builder: (context) => const TextParticlePage());

  @override
  State<TextParticlePage> createState() => _TextParticlePageState();
}

class _TextParticlePageState extends State<TextParticlePage> {
  final textController = TextEditingController(text: 'a');

  @override
  void initState() {
    super.initState();
    textController.addListener(
      () {
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TextParticle Animation'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: textController.text.isNotEmpty
                    ? TextParticleAnimation(
                        text: textController.text,
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            Text(
              'Text to particle',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 15),
            TextField(
              controller: textController,
              maxLength: 2,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
              decoration: InputDecoration(
                hintText: 'Enter text',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class TextParticleAnimation extends StatefulWidget {
  const TextParticleAnimation({
    super.key,
    required this.text,
  });
  final String text;

  static PageRoute route() =>
      MaterialPageRoute(builder: (context) => const TextParticlePage());

  @override
  State<TextParticleAnimation> createState() => _TextParticleAnimationState();
}

class _TextParticleAnimationState extends State<TextParticleAnimation>
    with SingleTickerProviderStateMixin {
  int particleCount = 1000;
  final _particles = <Particle>[];
  late Ticker _ticker;
  final _repaintNotifier = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _initializeTicker();
    _initGenerateParticles();
  }

  void _initializeTicker() {
    _ticker = Ticker((_) {
      for (Particle particle in _particles) {
        particle.update();
      }
      _repaintNotifier.value++;
      print("reading");
    });
  }

  void _reset() {
    _ticker.dispose();
    _particles.clear();
  }

  void _initGenerateParticles() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var view = ui.PlatformDispatcher.instance.views.first;
      var size = Size(
        view.physicalConstraints.maxWidth,
        view.physicalConstraints.maxHeight,
      );
      generateParticles(size / 4);
    });
  }

  @override
  void didUpdateWidget(covariant TextParticleAnimation oldWidget) {
    if (oldWidget.text != widget.text && widget.text.isNotEmpty) {
      _reset();
      _initializeTicker();
      _initGenerateParticles();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return CustomPaint(
      painter: TextParticlePainter(
        _particles,
        Theme.of(context).primaryColor,
        _repaintNotifier,
      ),
      size: size,
    );
  }

  Future<void> generateParticles(Size size) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: widget.text,
        style: TextStyle(
          fontSize: 240,
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )
      ..layout(
        minWidth: 0,
        maxWidth: MediaQuery.of(context).size.width,
      )
      ..paint(canvas, Offset.zero);
    final picture = recorder.endRecording();

    final uiImage = await picture.toImage(
      textPainter.width.ceil(),
      textPainter.height.ceil(),
    );
    final width = uiImage.width;
    final height = uiImage.height;
    final byteData =
        await uiImage.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) return;

    final pixels = byteData.buffer.asUint8List();
    final offsetX = (size.width - width) / 2;
    final offsetY = (size.height - height) / 2;

    for (int i = 0; i < particleCount; i++) {
      int x, y;

      do {
        x = math.Random().nextInt(width);
        y = math.Random().nextInt(height);
      } while (pixels[(((width * y) + x) * 4) + 3] < 128);

      _particles.add(
        Particle(
          position: Offset(
            -size.width + math.Random().nextDouble() * size.width * 2,
            math.Random().nextDouble() * size.height * 2,
          ),
          basePosition: Offset(
            x.toDouble() + offsetX,
            y.toDouble() + offsetY,
          ),
          density: 5 + math.Random().nextDouble() * 20,
        ),
      );
    }
    _ticker.start();
  }
}

class TextParticlePainter extends CustomPainter {
  TextParticlePainter(this.particles, this.color, this.listenable)
      : super(repaint: listenable);
  final List<Particle> particles;
  final Color color;
  final Listenable listenable;

  @override
  void paint(Canvas canvas, Size size) {
    for (Particle paricle in particles) {
      canvas.drawCircle(
        paricle.position,
        1,
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant TextParticlePainter oldDelegate) => false;
}
