import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart' hide TextDirection;

class Particle {
  Particle({
    required this.position,
    required this.mainPosition,
    required this.color,
  })  : startPosition = position,
        progress = 0.0,
        velocity = Offset.zero;

  Offset position;
  Offset mainPosition;
  final Offset startPosition;
  double progress;
  Color color;
  Offset velocity;
  // Spring constants
  double mass = 1.0;
  double stiffness = 120.0; // spring constant (higher = stiffer)
  // double damping = 20.0; // resistance (higher = slower bounce)

  void update({double duration = 0.016, double damping = -15.0}) {
    // if (progress < 1.0) {
    //   progress += duration;
    //   final eased = Curves.easeInOut.transform(progress.clamp(0.0, 1.0));
    //   position = Offset.lerp(startPosition, mainPosition, eased)!;
    // }
    final Offset displacement = mainPosition - position;
    final Offset springForce = displacement * stiffness;
    final Offset dampingForce = velocity * damping;
    final Offset force = springForce + dampingForce;
    final Offset acceleration = force / mass;

    velocity += acceleration * duration;
    position += velocity * duration;
  }
}

class ParticleClockPage extends StatefulWidget {
  const ParticleClockPage({super.key});

  static PageRoute route() =>
      MaterialPageRoute(builder: (context) => const ParticleClockPage());

  @override
  State<ParticleClockPage> createState() => _ParticleClockPageState();
}

class _ParticleClockPageState extends State<ParticleClockPage>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  List<Particle> _particles = [];
  List<List<Particle>> _particlesList = [];
  final _containerKey = GlobalKey();
  final _tickerNotifier = ValueNotifier(0);
  int _lastSecond = -1;
  String prevTime = '';
  double _progress = 0.016;
  double _damping = -15;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      final now = DateTime.now();
      if (now.second != _lastSecond) {
        _lastSecond = now.second;
        createParticle();
      }
      for (Particle particle in _particles) {
        particle.update(duration: _progress, damping: _damping);
      }
      _tickerNotifier.value++;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      createParticle();
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: const Text('Particle Clock')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Expanded(
              child: SizedBox(
                key: _containerKey,
                child: CustomPaint(
                  size: size,
                  painter: ClockPainter(_particles, _tickerNotifier),
                ),
              ),
            ),
            Slider.adaptive(
              value: _progress,
              max: 0.1,
              onChanged: (value) {
                setState(() {
                  _progress = value;
                });
              },
            ),
            const SizedBox(height: 20),
            Slider.adaptive(
              value: _damping,
              min: -25,
              max: -5,
              onChanged: (value) {
                setState(() {
                  _damping = value;
                });
              },
            ),
            const SizedBox(height: 50)
          ],
        ),
      ),
    );
  }

  Future<void> createParticle() async {
    final renderBox =
        _containerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final size = renderBox.size;

    final currentTime = DateFormat("HH:mm:ss").format(DateTime.now());
    List<bool> changesList = List.generate(
      currentTime.length,
      (i) => prevTime.length == currentTime.length
          ? currentTime[i] != prevTime[i]
          : false,
    );

    double offsetX = 0;
    if (_particlesList.isEmpty) {
      _particlesList = List.generate(currentTime.length, (i) => []);

      for (int i = 0; i < currentTime.length; i++) {
        final char = currentTime[i];
        final textPainter = TextPainter(
          text: TextSpan(
            text: char,
            style: const TextStyle(fontSize: 100),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        await _generateCharParticle(
          textPainter,
          size,
          char,
          Offset(offsetX, 0),
          changesList[i],
          i,
        );

        offsetX += textPainter.width;
      }
    } else {
      for (int i = 0; i < currentTime.length; i++) {
        final char = currentTime[i];
        final textPainter = TextPainter(
          text: TextSpan(
            text: char,
            style: const TextStyle(fontSize: 100),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        if (prevTime.isNotEmpty && currentTime[i] != prevTime[i]) {
          await _animateCharParticle(
            textPainter,
            size,
            char,
            Offset(offsetX, 0),
            changesList[i],
            i,
          );
        }

        offsetX += textPainter.width;
      }
    }

    prevTime = currentTime;
  }

  Future<void> _animateCharParticle(
    TextPainter textPainter,
    Size size,
    String char,
    Offset offset,
    bool animate,
    int index,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    textPainter.paint(canvas, Offset.zero);
    final picture = recorder.endRecording();

    final uiImage = await picture.toImage(
      textPainter.width.ceil(),
      textPainter.height.ceil(),
    );

    final byteData =
        await uiImage.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) return;

    final pixels = byteData.buffer.asUint8List();
    final width = uiImage.width;
    final height = uiImage.height;
    final offsetY = (size.height - height) / 2;

    final particle = List<Particle>.from(_particlesList[index]);
    if (animate) {
      _particlesList[index].clear();
    }

    for (int i = 0; i < particle.length; i++) {
      final p = particle[i];
      int x, y;
      do {
        x = math.Random().nextInt(width);
        y = math.Random().nextInt(height);
      } while (pixels[(((width * y) + x) * 4) + 3] < 128);

      final position = Offset(x.toDouble() + offset.dx, y.toDouble() + offsetY);
      final newParticle = Particle(
        position: p.mainPosition,
        mainPosition: position,
        color: p.color,
      );

      _particlesList[index].add(newParticle);
    }

    _particles = _particlesList.expand((e) => e).toList();
    setState(() {});
  }

  Future<void> _generateCharParticle(
    TextPainter textPainter,
    Size size,
    String char,
    Offset offset,
    bool animate,
    int index,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    textPainter.paint(canvas, Offset.zero);
    final picture = recorder.endRecording();

    final uiImage = await picture.toImage(
      textPainter.width.ceil(),
      textPainter.height.ceil(),
    );

    final byteData =
        await uiImage.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) return;

    final pixels = byteData.buffer.asUint8List();
    final width = uiImage.width;
    final height = uiImage.height;
    final offsetY = (size.height - height) / 2;

    if (animate) _particlesList[index].clear();

    for (int i = 0; i < 200; i++) {
      int x, y;
      do {
        x = math.Random().nextInt(width);
        y = math.Random().nextInt(height);
      } while (pixels[(((width * y) + x) * 4) + 3] < 128);

      final position = Offset(x.toDouble() + offset.dx, y.toDouble() + offsetY);

      final startPosition = animate
          ? Offset(
              math.Random().nextDouble() * width.toDouble() + offset.dx,
              math.Random().nextDouble() * height.toDouble() + offsetY,
            )
          : position;

      final particle = Particle(
        position: startPosition,
        mainPosition: position,
        color: Colors.primaries[math.Random().nextInt(Colors.primaries.length)],
      );

      _particlesList[index].add(particle);
    }

    _particles = _particlesList.expand((e) => e).toList();
    setState(() {});
  }
}

class ClockPainter extends CustomPainter {
  ClockPainter(this.particles, this.listenable) : super(repaint: listenable);
  final List<Particle> particles;
  final Listenable listenable;

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      canvas.drawCircle(
        particle.position,
        3,
        Paint()
          ..style = PaintingStyle.fill
          ..color = particle.color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
