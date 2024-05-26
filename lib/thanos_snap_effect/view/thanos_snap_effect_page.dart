import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:animation_playground/gen/assets.gen.dart';
import 'package:animation_playground/rainbow_sticks_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image/image.dart' as img;

class ThanosSnapEffectPage extends StatelessWidget {
  const ThanosSnapEffectPage({super.key});

  static PageRoute route() =>
      MaterialPageRoute(builder: (context) => const ThanosSnapEffectPage());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ThanosSnapEffect(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Assets.images.img3.image(),
                      ),
                    ),
                  ],
                ),
              ),
              ThanosSnapEffect(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: Assets.images.img2.image(
                              height: 300,
                            ),
                            title: Text(
                              'Tomiwa Idowu',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                            ),
                            subtitle: Text(
                              'Mobile Engineer 💙',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: Colors.white,
                                  ),
                            ),
                            trailing: const Icon(Iconsax.arrow_right_3),
                          ),
                        ],
                      ),
                    ),
                    Card(
                      child: ListTile(
                        title: Text(
                          'Hire me 🙂‍↕️',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                  ),
                        ),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        title: Text(
                          'Open to remote roles',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                  ),
                        ),
                        trailing: const Icon(Iconsax.arrow_right_3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ThanosSnapEffect extends StatefulWidget {
  const ThanosSnapEffect({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<ThanosSnapEffect> createState() => _ThanosSnapEffectState();
}

class _ThanosSnapEffectState extends State<ThanosSnapEffect>
    with SingleTickerProviderStateMixin {
  final _widgetAsImageKey = GlobalKey();
  final _particlesList = List<Uint8List>.empty(growable: true);
  late AnimationController _animationController;
  final _particleSize = 25;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startAnimation() {
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleSnapEffect,
      child: Stack(
        children: [
          ..._particlesList.map((e) {
            final index = _particlesList.indexOf(e);
            final beginInterval = (index / _particlesList.length) * 0.6;
            final endInterval = math.max(beginInterval * 0.3, 1).toDouble();
            final endOffset = toPolar(
                MediaQuery.sizeOf(context).center(Offset.zero),
                index,
                _particlesList.length,
                100);
            final transformAnimation = Tween<Offset>(
              begin: Offset.zero,
              end: Offset(
                  endOffset.dx.toInt().isEven
                      ? endOffset.dx / 2
                      : -endOffset.dx / 2,
                  -endOffset.dy),
            ).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(
                  beginInterval,
                  endInterval,
                  curve: Curves.easeOutQuint,
                ),
              ),
            );
            final fadeAnimation = Tween<double>(
              begin: 1,
              end: math.min(index / _particlesList.length, 0),
            ).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(
                  beginInterval,
                  endInterval,
                  curve: Curves.easeOut,
                ),
              ),
            );
            return AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) => Transform.translate(
                offset: transformAnimation.value,
                child: FadeTransition(
                  opacity: fadeAnimation,
                  child: Image.memory(e),
                ),
              ),
              child: Image.memory(e),
            );
          }),
          AnimatedOpacity(
            opacity: _animationController.isDismissed ? 1 : 0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            child: RepaintBoundary(
              key: _widgetAsImageKey,
              child: Theme(data: ThemeData.dark(), child: widget.child),
            ),
          ),
        ],
      ),
    );
  }

  ///This triggers the snapEffect and start the animation
  Future<void> _handleSnapEffect() async {
    //Get the captured widget as a [Uint8List]
    final capturedImageList = await _captureWidgetAsImageList();
    //If the capturedImage is null stop the operation
    if (capturedImageList == null) return;

    //Generate list of captured images with captured image and particle size
    final images = _generateImageDistribution(capturedImageList);

    //If generated image is empty stop the operation
    if (images.isEmpty) return;

    //Convert generated image to [Uint8List] type
    //so we can make use of Image.memory
    _particlesList.addAll(images.map((e) => img.encodePng(e)).toList());
    setState(() {});

    //After all the operation
    //start the animationController
    _startAnimation();
  }

  List<img.Image> _generateImageDistribution(Uint8List imageData) {
    final decodedImage = img.decodePng(imageData);
    if (decodedImage == null) return [];
    final imageDataList = List<img.Image>.generate(
      _particleSize,
      (index) => img.Image(
        width: decodedImage.width,
        height: decodedImage.height,
        numChannels: 4,
      ),
    );

    for (var y = 0; y < decodedImage.height; y++) {
      for (var x = 0; x < decodedImage.width; x++) {
        final weights = List.generate(
            _particleSize,
            (index) => math.Random()
                .nextInt(decodedImage.height * decodedImage.width));
        final index = _weightedRandomDistribution(weights, _particleSize);
        final pixel = decodedImage.getPixelSafe(x, y);
        if (index == 0) {
          pixel.a = 1;
        }
        imageDataList[index].setPixel(x, y, pixel);
      }
    }
    return imageDataList;
  }

  ///Use to capture the image wrap with repaintboundary widget
  ///using the global key
  Future<Uint8List?> _captureWidgetAsImageList() async {
    //find the repaintboundary context renderobject using the assigned widget key
    final repaintBoundry = _widgetAsImageKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;

    //if it does not find the render object
    //return null else continue the operation
    if (repaintBoundry == null) return null;

    //Capture an image of the current state of the repaintboundary render object
    final img = await repaintBoundry.toImage();

    //Convert the captured image into byte array
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    //Get the byteData as Uint8List
    final image = byteData?.buffer.asUint8List();
    return image;
  }

  ///Random weighted distribution algo
  int _weightedRandomDistribution(List<int> weights, int weightSize) {
    //Calculate the total weight
    final sumOfWeight = weights.reduce((value, element) => value + element);

    //This acts like a compute property
    int randonmize() => math.Random().nextInt(sumOfWeight);

    //Generate random number within the range of 1 and sumOfWeight
    int rndNum = randonmize();

    //Walkthrough the space, moving the cursor from top to bottom
    int cursor = 0;
    for (var i = 0; i < weightSize; i++) {
      //is the current weight greater than the random number
      //if yes return the index
      if (weights[i] > rndNum) {
        cursor = i;
        break;
      }
      //if no randomize again
      rndNum = randonmize();
    }
    return cursor;
  }
}
