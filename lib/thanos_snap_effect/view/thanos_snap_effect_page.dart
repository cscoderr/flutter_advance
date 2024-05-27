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
      appBar: AppBar(
        title: const Text('Thanos Snap Effect'),
      ),
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
  final _imageDataList = List<Uint8List>.empty(growable: true);
  late AnimationController _animationController;

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
          //Fades the actual widget when the animation start
          AnimatedOpacity(
            opacity: _animationController.isDismissed ? 1 : 0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            child: RepaintBoundary(
              key: _widgetAsImageKey,
              child: Theme(data: ThemeData.dark(), child: widget.child),
            ),
          ),
          //Loop throught the imageDataList and animate accordingly
          ..._imageDataList.map(_animateImageData),
        ],
      ),
    );
  }

  Widget _animateImageData(Uint8List imageData) {
    //Get the current index of the imageData
    final index = _imageDataList.indexOf(imageData);

    //Calculate the animation start interval
    //based on the index and lenght of imageDataList
    final beginInterval = (index / _imageDataList.length) * 0.6;

    //Calculate the animation end interval
    //based on the start interval
    final endInterval = math.max(beginInterval * 0.3, 1).toDouble();
    final endOffset = toPolar(MediaQuery.sizeOf(context).center(Offset.zero),
        index, _imageDataList.length, 100);

    final curvedAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        beginInterval,
        endInterval,
        curve: Curves.easeOut,
      ),
    );

    final transformAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(
          endOffset.dx.toInt().isEven ? endOffset.dx / 2 : -endOffset.dx / 2,
          -endOffset.dy),
    ).animate(curvedAnimation);

    final fadeAnimation = Tween<double>(
      begin: 1,
      end: math.min(index / _imageDataList.length, 0),
    ).animate(curvedAnimation);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) => Transform.translate(
        offset: transformAnimation.value,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: child,
        ),
      ),
      child: Image.memory(imageData),
    );
  }

  ///This triggers the snapEffect and start the animation
  Future<void> _handleSnapEffect() async {
    //Get the captured widget as a [Uint8List]
    final capturedImageList = await _captureWidgetAsImageList();
    //If the capturedImage is null stop the operation
    if (capturedImageList == null) return;

    //This can be any value
    const imageDataListSize = 25;

    //Generate list of captured images with captured image and imageDataListSize
    final images =
        _generateImageDistribution(capturedImageList, imageDataListSize);

    //If generated image is empty stop the operation
    if (images.isEmpty) return;

    //Convert generated image to [Uint8List] type
    //so we can make use of Image.memory
    _imageDataList.addAll(images.map((e) => img.encodePng(e)).toList());
    setState(() {});

    //After all the operation
    //start the animationController
    _startAnimation();
  }

  ///Use to generate image based on captured image and imageDataListSize
  ///More like breaking the captured image into chunks of given imageDataListSize
  List<img.Image> _generateImageDistribution(
      Uint8List imageData, int imageDataListSize) {
    //Convert the imageData into PNG format
    final decodedImage = img.decodePng(imageData);

    //Stop the excution when the image converstion fails
    if (decodedImage == null) return [];

    //Generate empty Image list based on the imageDataListSize
    final imageDataList = List<img.Image>.generate(
      imageDataListSize,
      (index) => img.Image(
        width: decodedImage.width,
        height: decodedImage.height,
        numChannels: 4,
      ),
    );

    //Loop through the converted png image width and height
    //Replace generated empty image with the actual image
    //based on weighted random distribution
    for (var y = 0; y < decodedImage.height; y++) {
      for (var x = 0; x < decodedImage.width; x++) {
        //Generate random weights with the imageDataListSize
        final weights = List.generate(
          imageDataListSize,
          (index) =>
              math.Random().nextInt(decodedImage.height * decodedImage.width),
        );

        //Generate index based on the weighted random distribution algo
        //using the List of weights, pimageDataListSize and sumOfweights
        final index = _weightedRandomDistribution(weights, imageDataListSize);

        //Get the converted png image pixel based on the x and y value
        final pixel = decodedImage.getPixelSafe(x, y);

        //Added this check to reduce the first image
        //pixel alpha value because it looks like the actual
        //captured image
        if (index == 0) {
          pixel.a = 1;
        }

        //Assign the converted png image pixel to the empty image
        //based on the index returned from weighted random distribution
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
