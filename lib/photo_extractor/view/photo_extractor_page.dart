import 'dart:ui' as ui;

import 'package:animation_playground/gen/assets.gen.dart';
import 'package:animation_playground/photo_extractor/photo_extractor.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

class PhotoExtractor extends StatefulWidget {
  const PhotoExtractor({super.key});

  static PageRoute route() =>
      MaterialPageRoute(builder: (_) => const PhotoExtractor());

  @override
  State<PhotoExtractor> createState() => _PhotoExtractorState();
}

class _PhotoExtractorState extends State<PhotoExtractor>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _animationController2;
  late Animation<double> _animation;
  late Animation<double> _heightAnimation;
  bool isDestroy = false;
  bool show = true;
  bool isDestroying = false;
  bool hasExtract = false;
  bool showMid = false;
  List<Widget> stripes = [];
  ui.Image? _image;
  late AudioPlayer player;
  final _innerLineHeight = 10.0;
  final _outerLineHeight = 24.0;
  final _numberOfStripe = 10;
  late double _imageHeight;
  late double _imageWidth;
  double _clipHeight = 0;
  final int _extraSize = 70;

  @override
  void initState() {
    super.initState();

    player = AudioPlayer();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
      upperBound: 1.1,
    );

    _animationController2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // MediaQuery.sizeOf(context).height * 0.47

      _imageWidth = MediaQuery.sizeOf(context).width * 0.82;
      _imageHeight = _imageWidth;

      _clipHeight = _outerLineHeight / 2 + _imageHeight + _extraSize + 30;
      _heightAnimation = Tween(begin: 0.0, end: _imageHeight + _extraSize)
          .animate(_animationController);
    });

    _loadImage();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _animationController2.dispose();
    player.dispose();
    super.dispose();
  }

  Future<void> _loadImage() async {
    final bytes = await rootBundle.load(Assets.images.img3.path);
    final codec = await ui.instantiateImageCodec(
      bytes.buffer.asUint8List(),
      targetWidth: _imageWidth.round(),
      targetHeight: _imageHeight.round(),
    );
    final frame = await codec.getNextFrame();

    setState(() {
      _image = frame.image;
      _animation =
          Tween(begin: 0.0, end: MediaQuery.sizeOf(context).height).animate(
        CurvedAnimation(
          parent: _animationController2,
          curve: Curves.easeInOut,
        ),
      );
    });
  }

  void _handleDestroy() {
    setState(() {
      isDestroy = !isDestroy;
    });

    Future.delayed(const Duration(milliseconds: 2000), () {
      _playExtractorSound();

      setState(() {
        isDestroying = true;
      });
      _animationController2.forward().then((value) {
        setState(() {
          isDestroy = false;
          showMid = false;
          hasExtract = false;
          isDestroying = false;
          show = false;
        });
        Future.delayed(Durations.extralong4, () {
          setState(() {
            show = true;
          });
          _animationController.reset();
          _animationController2.reset();
        });
      });
    });
  }

  void _playPaperSound() {
    player.play(AssetSource('sounds/Papersound.mp3'));
  }

  void _playStampSound() {
    player.play(AssetSource('sounds/Stampsound.mp3'));
  }

  void _playExtractorSound() {
    player.play(AssetSource('sounds/PhotoExtractor.mp3'));
  }

  void _handleExtract() {
    const springDescription = SpringDescription(
      mass: 0.7,
      stiffness: 200.0,
      damping: 20.0,
    );
    final simulation = SpringSimulation(
      springDescription,
      _animationController.value,
      0.3,
      _animationController.velocity,
    );
    _animationController.animateWith(simulation);
    Future.delayed(Durations.extralong4, () {
      _playStampSound();
      const springDescription = SpringDescription(
        mass: 0.8,
        stiffness: 180.0,
        damping: 20.0,
      );
      final simulation = SpringSimulation(springDescription,
          _animationController.value, 1, _animationController.velocity);
      _animationController.animateWith(simulation);
      setState(() {
        hasExtract = true;
      });
    });

    _playPaperSound();
    setState(() {
      showMid = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Expanded(
                child: _image == null
                    ? const SizedBox.shrink()
                    : () {
                        final rect = Rect.fromLTWH(
                          (size.width - 20 - _imageWidth) / 2,
                          _outerLineHeight / 2 - _imageHeight,
                          _imageWidth,
                          _imageHeight,
                        );
                        final stripeWidth = _imageWidth / _numberOfStripe;
                        final maxHeight =
                            _outerLineHeight / 2 + _imageHeight + 70 + 30;
                        return Stack(
                          children: [
                            _buildStripeImages(
                              rect: rect,
                              stripeWidth: stripeWidth,
                              imageHeight: _imageHeight,
                            ),
                            _buildOuterLine(),
                            _buildInnerLine(),
                            _buildMainImage(rect: rect, imageHeight: maxHeight),
                            if (showMid && !hasExtract)
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 500),
                                top: 12,
                                left: 25,
                                right: 25,
                                child: Container(
                                  height: 30,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black.withOpacity(0.5),
                                        Colors.transparent,
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      }(),
              ),
              _buildExtractAndDestroyButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExtractAndDestroyButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: isDestroy ? null : _handleExtract,
          child: const Text('Extract'),
        ),
        ElevatedButton(
          onPressed: _handleDestroy,
          child: const Text('Destroy'),
        )
      ],
    );
  }

  Widget _buildOuterLine() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      top: isDestroy ? _clipHeight : 0,
      left: 0,
      right: 0,
      height: _outerLineHeight,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFDEE3),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildInnerLine() {
    final topSpacing = (_outerLineHeight - _innerLineHeight) / 2;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      top: isDestroy ? _clipHeight + topSpacing : topSpacing,
      left: 10,
      right: 10,
      height: _innerLineHeight,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF650A31),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildMainImage({
    required Rect rect,
    required double imageHeight,
  }) {
    return Positioned(
      top: _outerLineHeight / 2,
      left: 0,
      right: 0,
      height: imageHeight,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 700),
        offset: Offset(0, show ? 0 : -1),
        child: MainImageStack(
          rect: rect,
          innerLineHeight: _innerLineHeight,
          image: _image!,
          heightAnimation: _heightAnimation,
          heightAnimation2: _animation,
        ),
      ),
    );
  }

  Widget _buildStripeImages(
      {required Rect rect,
      required double stripeWidth,
      required double imageHeight}) {
    return Positioned.fromRect(
      rect: rect,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: StripePainter(
            _image!,
            _animationController2,
            _heightAnimation,
            _animation,
            numberOfStripe: _numberOfStripe,
            stripeWidth: stripeWidth,
            imageHeight: imageHeight,
          ),
        ),
      ),
    );
  }
}
