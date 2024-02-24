import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhotoExtractor extends StatefulWidget {
  const PhotoExtractor({super.key});

  static PageRoute route() =>
      MaterialPageRoute(builder: (_) => const PhotoExtractor());

  @override
  State<PhotoExtractor> createState() => _PhotoExtractorState();
}

class _PhotoExtractorState extends State<PhotoExtractor> {
  Future<ui.Image> getUiImage(
      String imageAssetPath, int height, int width) async {
    final ByteData assetImageByteData = await rootBundle.load(imageAssetPath);
    final codec = await ui.instantiateImageCodec(
      assetImageByteData.buffer.asUint8List(),
      targetHeight: height,
      targetWidth: width,
    );
    final image = (await codec.getNextFrame()).image;
    return image;
  }

  // List<image> splitimage(List<int> input) {
  //   // convert image to image from image package
  //   final images = image.decodeimage(input);

  //   int x = 0, y = 0;
  //   int width = (images.width / 3).round();
  //   int height = (images.height / 3).round();

  //   // split image to parts
  //   final parts = <Image>[];
  //   for (int i = 0; i < 3; i++) {
  //     for (int j = 0; j < 3; j++) {
  //       parts.add(images.copycrop(images, x, y, width, height));
  //       x += width;
  //     }
  //     x = 0;
  //     y += height;
  //   }

  //   // convert image from image package to image widget to display
  //   List<Image> output = List<Image>();
  //   for (var img in parts) {
  //     output.add(image.memory(image.encodejpg(img)));
  //   }

  //   return output;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            FutureBuilder(
                future: getUiImage("assets/images/feature3.png", 100, 100),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      snapshot.error == true ||
                      snapshot.data == null) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ShaderMask(
                    shaderCallback: (bounds) => ImageShader(
                      snapshot.data!,
                      TileMode.mirror,
                      TileMode.mirror,
                      Float64List.fromList(
                        [1.0, 1, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1, 1, 1, 0, 0],
                      ),
                    ),
                    child: Image.asset(
                      "assets/images/feature3.png",
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
