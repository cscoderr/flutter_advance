import 'dart:ui' as ui;

import 'package:animation_playground/gen/assets.gen.dart';
import 'package:animation_playground/photo_extractor/photo_extractor.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';

class PhotoExtractor extends StatefulWidget {
  const PhotoExtractor({super.key});

  static PageRoute route() =>
      MaterialPageRoute(builder: (_) => const PhotoExtractor());

  @override
  State<PhotoExtractor> createState() => _PhotoExtractorState();
}

class _PhotoExtractorState extends State<PhotoExtractor>
    with TickerProviderStateMixin {
  late AnimationController _springAnimationController;
  late AnimationController _animationController;
  late AnimationController _verticesAnimationController;

  late Animation<double> _midHeightAnimation;
  late Animation<double> _fullHeightAnimation;
  late AudioPlayer player;

  ui.Image? _image;

  //Flags
  bool isDestroy = false;
  bool performSlideAnimation = false;
  bool showGradientOverlay = false;

  //
  late double _imageHeight;
  late double _imageWidth;

  //Constants
  final _innerLineHeight = 10.0;
  final _outerLineHeight = 24.0;
  final _numberOfStripe = 10;
  double _clippedHeight = 0;
  final int _extraSize = 70;
  final int _minExtraSize = 30;
  final String _imagePath = Assets.images.img4.path;

  @override
  void initState() {
    super.initState();

    player = AudioPlayer();

    _springAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
      upperBound: 1.1,
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _verticesAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _loadImage();
      _imageWidth = MediaQuery.sizeOf(context).width * 0.82;
      _imageHeight = _imageWidth;

      _clippedHeight =
          _outerLineHeight / 2 + _imageHeight + _extraSize + _minExtraSize;
      _midHeightAnimation = Tween(begin: 0.0, end: _imageHeight + _extraSize)
          .animate(_springAnimationController);
    });
  }

  @override
  void dispose() {
    _springAnimationController.dispose();
    _animationController.dispose();
    _verticesAnimationController.dispose();
    player.dispose();
    super.dispose();
  }

  void _handleDestroy() {
    setState(() {
      isDestroy = true;
    });

    Future.delayed(const Duration(milliseconds: 2000), () {
      _playExtractorSound();
      _verticesAnimationController.forward();

      _animationController.forward().then((value) {
        setState(() {
          performSlideAnimation = true;
          isDestroy = false;
        });
        Future.delayed(Durations.extralong4, () {
          _resetAnimation();
          setState(() {
            performSlideAnimation = false;
          });
        });
      });
    });
  }

  void _resetAnimation() {
    _springAnimationController.reset();
    _animationController.reset();
    _verticesAnimationController.reset();
  }

  //Hanle the image extract
  void _handleExtract() {
    _playPaperSound();

    //Update the linear gradient overlay to false
    setState(() {
      showGradientOverlay = true;
    });

    const springDescription = SpringDescription(
      mass: 0.7,
      stiffness: 200.0,
      damping: 20.0,
    );
    final simulation = SpringSimulation(
      springDescription,
      _springAnimationController.value,
      0.3,
      _springAnimationController.velocity,
    );
    _springAnimationController.animateWith(simulation);

    //Wait from 1 seconds before sliding the full image out
    Future.delayed(Durations.extralong4, () {
      _playStampSound();

      //Update the linear gradient overlay to false
      setState(() {
        showGradientOverlay = false;
      });
      const springDescription = SpringDescription(
        mass: 0.8,
        stiffness: 180.0,
        damping: 20.0,
      );
      final simulation = SpringSimulation(
        springDescription,
        _springAnimationController.value,
        1.0,
        _springAnimationController.velocity,
      );
      _springAnimationController.animateWith(simulation);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _image == null
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    Expanded(
                      child: () {
                        final rect = Rect.fromLTWH(
                          (size.width - 20 - _imageWidth) / 2,
                          _outerLineHeight / 2 - _imageHeight,
                          _imageWidth,
                          _imageHeight,
                        );
                        final stripeWidth = _imageWidth / _numberOfStripe;

                        return Stack(
                          children: [
                            _buildStripeImages(
                                rect: rect, stripeWidth: stripeWidth),
                            _buildOuterLine(),
                            _buildInnerLine(),
                            _buildMainImage(rect: rect),
                            _buildGradientOverlay(),
                          ],
                        );
                      }(),
                    ),
                    _buildExtractAndDestroyButton(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildExtractAndDestroyButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed:
              _springAnimationController.status == AnimationStatus.forward ||
                      _animationController.status == AnimationStatus.forward ||
                      isDestroy
                  ? () {}
                  : _handleExtract,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF650A31),
            foregroundColor: Colors.white,
            textStyle: Theme.of(context).textTheme.bodyLarge,
          ),
          icon: const Icon(Iconsax.export),
          label: const Text('Extract'),
        ),
        ElevatedButton.icon(
          onPressed: isDestroy ? () {} : _handleDestroy,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF650A31),
            foregroundColor: Colors.white,
            textStyle: Theme.of(context).textTheme.bodyLarge,
          ),
          icon: const Icon(Iconsax.trash),
          label: const Text('Destroy'),
        )
      ],
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned(
      top: 12,
      left: 25,
      right: 25,
      child: AnimatedOpacity(
        opacity: showGradientOverlay ? 1 : 0,
        duration: const Duration(milliseconds: 300),
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
    );
  }

  Widget _buildOuterLine() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      top: isDestroy ? _clippedHeight : 0,
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
      top: isDestroy ? _clippedHeight + topSpacing : topSpacing,
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
  }) {
    final height =
        _outerLineHeight / 2 + _imageHeight + _extraSize + _minExtraSize;
    return Positioned(
      top: _outerLineHeight / 2,
      left: 0,
      right: 0,
      height: height,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 700),
        offset: Offset(0, performSlideAnimation ? -1 : 0),
        child: MainImageStack(
          rect: rect,
          innerLineHeight: _innerLineHeight,
          image: _image!,
          midHeightAnimation: _midHeightAnimation,
          fullHeightAnimation: _fullHeightAnimation,
          imagePath: _imagePath,
        ),
      ),
    );
  }

  Widget _buildStripeImages({required Rect rect, required double stripeWidth}) {
    return AnimatedBuilder(
      animation: Listenable.merge([_midHeightAnimation, _fullHeightAnimation]),
      builder: (context, child) {
        return Positioned.fromRect(
          rect: rect,
          child: Transform.translate(
            offset: Offset(
                0, _midHeightAnimation.value + _fullHeightAnimation.value + 20),
            child: child,
          ),
        );
      },
      child: RepaintBoundary(
        child: CustomPaint(
          painter: StripePainter(
            _image!,
            _verticesAnimationController,
            numberOfStripe: _numberOfStripe,
            stripeWidth: stripeWidth,
            imageHeight: _imageHeight,
          ),
        ),
      ),
    );
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

  Future<void> _loadImage() async {
    final bytes = await rootBundle.load(_imagePath);
    final codec = await ui.instantiateImageCodec(
      bytes.buffer.asUint8List(),
      targetWidth: _imageWidth.round(),
      targetHeight: _imageHeight.round(),
    );
    final frame = await codec.getNextFrame();

    setState(() {
      _image = frame.image;
      _fullHeightAnimation =
          Tween(begin: 0.0, end: MediaQuery.sizeOf(context).height).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeInOut,
        ),
      );
    });
  }
}
