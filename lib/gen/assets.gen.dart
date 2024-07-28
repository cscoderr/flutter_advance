/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class $AssetsIconsGen {
  const $AssetsIconsGen();

  /// File path: assets/icons/angle-left.png
  AssetGenImage get angleLeft =>
      const AssetGenImage('assets/icons/angle-left.png');

  /// File path: assets/icons/angle-right.png
  AssetGenImage get angleRight =>
      const AssetGenImage('assets/icons/angle-right.png');

  /// List of all assets
  List<AssetGenImage> get values => [angleLeft, angleRight];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/bedroom1.jpg
  AssetGenImage get bedroom1 =>
      const AssetGenImage('assets/images/bedroom1.jpg');

  /// File path: assets/images/bedroom10.jpg
  AssetGenImage get bedroom10 =>
      const AssetGenImage('assets/images/bedroom10.jpg');

  /// File path: assets/images/bedroom2.jpg
  AssetGenImage get bedroom2 =>
      const AssetGenImage('assets/images/bedroom2.jpg');

  /// File path: assets/images/bedroom3.jpg
  AssetGenImage get bedroom3 =>
      const AssetGenImage('assets/images/bedroom3.jpg');

  /// File path: assets/images/bedroom4.jpg
  AssetGenImage get bedroom4 =>
      const AssetGenImage('assets/images/bedroom4.jpg');

  /// File path: assets/images/bedroom5.jpg
  AssetGenImage get bedroom5 =>
      const AssetGenImage('assets/images/bedroom5.jpg');

  /// File path: assets/images/bedroom6.jpg
  AssetGenImage get bedroom6 =>
      const AssetGenImage('assets/images/bedroom6.jpg');

  /// File path: assets/images/bedroom7.jpg
  AssetGenImage get bedroom7 =>
      const AssetGenImage('assets/images/bedroom7.jpg');

  /// File path: assets/images/bedroom8.jpg
  AssetGenImage get bedroom8 =>
      const AssetGenImage('assets/images/bedroom8.jpg');

  /// File path: assets/images/bedroom9.jpg
  AssetGenImage get bedroom9 =>
      const AssetGenImage('assets/images/bedroom9.jpg');

  /// File path: assets/images/dash.png
  AssetGenImage get dash => const AssetGenImage('assets/images/dash.png');

  /// File path: assets/images/feature1.png
  AssetGenImage get feature1 =>
      const AssetGenImage('assets/images/feature1.png');

  /// File path: assets/images/feature2.png
  AssetGenImage get feature2 =>
      const AssetGenImage('assets/images/feature2.png');

  /// File path: assets/images/feature3.png
  AssetGenImage get feature3 =>
      const AssetGenImage('assets/images/feature3.png');

  /// File path: assets/images/img.png
  AssetGenImage get img => const AssetGenImage('assets/images/img.png');

  /// File path: assets/images/img2.png
  AssetGenImage get img2 => const AssetGenImage('assets/images/img2.png');

  /// File path: assets/images/img3.jpeg
  AssetGenImage get img3 => const AssetGenImage('assets/images/img3.jpeg');

  /// File path: assets/images/img4.jpeg
  AssetGenImage get img4 => const AssetGenImage('assets/images/img4.jpeg');

  /// File path: assets/images/tarot_back.png
  AssetGenImage get tarotBack =>
      const AssetGenImage('assets/images/tarot_back.png');

  /// File path: assets/images/tarot_front.png
  AssetGenImage get tarotFront =>
      const AssetGenImage('assets/images/tarot_front.png');

  /// List of all assets
  List<AssetGenImage> get values => [
        bedroom1,
        bedroom10,
        bedroom2,
        bedroom3,
        bedroom4,
        bedroom5,
        bedroom6,
        bedroom7,
        bedroom8,
        bedroom9,
        dash,
        feature1,
        feature2,
        feature3,
        img,
        img2,
        img3,
        img4,
        tarotBack,
        tarotFront
      ];
}

class $AssetsSoundsGen {
  const $AssetsSoundsGen();

  /// File path: assets/sounds/Papersound.mp3
  String get papersound => 'assets/sounds/Papersound.mp3';

  /// File path: assets/sounds/PhotoExtractor.mp3
  String get photoExtractor => 'assets/sounds/PhotoExtractor.mp3';

  /// File path: assets/sounds/Stampsound.mp3
  String get stampsound => 'assets/sounds/Stampsound.mp3';

  /// List of all assets
  List<String> get values => [papersound, photoExtractor, stampsound];
}

class Assets {
  Assets._();

  static const $AssetsIconsGen icons = $AssetsIconsGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const $AssetsSoundsGen sounds = $AssetsSoundsGen();
}

class AssetGenImage {
  const AssetGenImage(this._assetName);

  final String _assetName;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
