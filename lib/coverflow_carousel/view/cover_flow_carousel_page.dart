import 'package:animation_playground/gen/assets.gen.dart';
import 'package:flutter/material.dart';

class CoverFlowCarouselPage extends StatefulWidget {
  const CoverFlowCarouselPage({super.key});

  static PageRoute route() =>
      MaterialPageRoute(builder: (context) => const CoverFlowCarouselPage());

  @override
  State<CoverFlowCarouselPage> createState() => _CoverFlowCarouselPageState();
}

class _CoverFlowCarouselPageState extends State<CoverFlowCarouselPage> {
  late PageController _pageController;
  final _maxHeight = 150.0;
  final _minItemWidth = 40.0;
  double _currentPageIndex = 0;
  final _spacing = 10.0;
  final _images = [
    Assets.images.bedroom1.path,
    Assets.images.bedroom2.path,
    Assets.images.bedroom3.path,
    Assets.images.bedroom4.path,
    Assets.images.bedroom5.path,
    Assets.images.bedroom6.path,
    Assets.images.bedroom7.path,
    Assets.images.bedroom8.path,
    Assets.images.bedroom9.path,
    Assets.images.bedroom10.path,
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _currentPageIndex.toInt(),
    );
    _pageController.addListener(_pageControllerListener);
  }

  void _pageControllerListener() {
    setState(() {
      _currentPageIndex = _pageController.page ?? 0;
    });
  }

  @override
  void dispose() {
    _pageController.removeListener(_pageControllerListener);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: _maxHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: Stack(
                  children: _images.asMap().entries.map((item) {
                    final currentIndex = _currentPageIndex - item.key;
                    return _CoverFlowPositionedItem(
                      imagePath: item.value,
                      index: currentIndex,
                      absIndex: currentIndex.abs(),
                      size: Size(screenWidth, _maxHeight),
                      minItemWidth: _minItemWidth,
                      maxItemWidth: screenWidth / 2,
                      spacing: _spacing,
                    );
                  }).toList(),
                ),
              ),
              Positioned.fill(
                child: PageView.builder(
                  controller: _pageController,
                  itemBuilder: (context, index) => const SizedBox.expand(),
                  itemCount: _images.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoverFlowPositionedItem extends StatelessWidget {
  const _CoverFlowPositionedItem({
    required this.imagePath,
    required this.index,
    required this.absIndex,
    required this.size,
    required this.minItemWidth,
    required this.maxItemWidth,
    required this.spacing,
  });
  final String imagePath;
  final double index;
  final double absIndex;
  final Size size;
  final double minItemWidth;
  final double maxItemWidth;
  final double spacing;

  double get _getItemPosition {
    final centerPosition = size.width / 2;
    final mainPosition = centerPosition - (maxItemWidth / 2);
    if (index == 0) return mainPosition;
    return _calculateNewMainPosition(mainPosition);
  }

  double get _calculateItemWidth {
    final diffWidth = maxItemWidth - minItemWidth;
    final newMaxItemWidth = maxItemWidth - (diffWidth * absIndex);
    return absIndex < 1 ? newMaxItemWidth : minItemWidth;
  }

  double get _getScaleValue => 1 - (0.15 * absIndex);

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(_getItemPosition, 0),
      child: Transform.scale(
        scale: _getScaleValue,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            width: _calculateItemWidth,
            height: size.height,
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  double _calculateLeftPosition(double mainPosition) {
    return absIndex <= 1 ? mainPosition : (mainPosition - minItemWidth);
  }

  double _calculateRightPosition(double mainPosition) {
    final totalItemWidth = maxItemWidth + minItemWidth;
    return absIndex <= 1 ? mainPosition : mainPosition + totalItemWidth;
  }

  double _calculateRightAndLeftDiffPosition() {
    return absIndex <= 1.0
        ? ((index > 0 ? minItemWidth : maxItemWidth) * absIndex)
        : ((index > 0 ? (absIndex - 1) : (absIndex - 2)) * minItemWidth);
  }

  double _calculateNewMainPosition(double mainPosition) {
    final diffPosition = _calculateRightAndLeftDiffPosition();
    final leftPosition = _calculateLeftPosition(mainPosition);
    final rightPosition = _calculateRightPosition(mainPosition);
    return index > 0
        ? leftPosition - diffPosition - spacing
        : rightPosition + diffPosition + spacing;
  }
}
