// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

typedef _ChildSizingFunction = double Function(RenderBox child);

/// A delegate used by [RenderCircleListViewport] to manage its children.
///
/// [RenderCircleListViewport] during layout will ask the delegate to create
/// children that are visible in the viewport and remove those that are not.
abstract class CircleListChildManager {
  /// The maximum number of children that can be provided to
  /// [RenderCircleListViewport].
  ///
  /// If non-null, the children will have index in the range [0, childCount - 1].
  ///
  /// If null, then there's no explicit limits to the range of the children
  /// except that it has to be contiguous. If [childExistsAt] for a certain
  /// index returns false, that index is already past the limit.
  int? get childCount;

  /// Checks whether the delegate is able to provide a child widget at the given
  /// index.
  ///
  /// This function is not about whether the child at the given index is
  /// attached to the [RenderCircleListViewport] or not.
  bool childExistsAt(int index);

  /// Creates a new child at the given index and updates it to the child list
  /// of [RenderCircleListViewport]. If no child corresponds to `index`, then do
  /// nothing.
  ///
  /// It is possible to create children with negative indices.
  void createChild(int index, {required RenderBox? after});

  /// Removes the child element corresponding with the given RenderBox.
  void removeChild(RenderBox? child);
}

/// [ParentData] for use with [RenderCircleListViewport].
class CircleListParentData extends ContainerBoxParentData<RenderBox> {
  /// Index of this child in its parent's child list.
  int? index;
}

/// Render, onto a wheel, a bigger sequential set of objects inside this viewport.
///
/// Takes a scrollable set of fixed sized [RenderBox]es and renders them
/// sequentially from top down on a vertical scrolling axis.
///
/// It starts with the first scrollable item in the center of the main axis
/// and ends with the last scrollable item in the center of the main axis. This
/// is in contrast to typical lists that start with the first scrollable item
/// at the start of the main axis and ends with the last scrollable item at the
/// end of the main axis.
///
/// Instead of rendering its children on a flat plane, it renders them
/// as if each child is broken into its own plane and that plane is
/// perpendicularly fixed onto a cylinder which rotates along the scrolling
/// axis.
///
/// This class works in 3 coordinate systems:
///
/// 1. The **scrollable layout coordinates**. This coordinate system is used to
///    communicate with [ViewportOffset] and describes its children's abstract
///    offset from the beginning of the scrollable list at (0.0, 0.0).
///
///    The list is scrollable from the start of the first child item to the
///    start of the last child item.
///
///    Children's layout coordinates don't change as the viewport scrolls.
///
/// 2. The **untransformed plane's viewport painting coordinates**. Children are
///    not painted in this coordinate system. It's an abstract intermediary used
///    before transforming into the next cylindrical coordinate system.
///
///    This system is the **scrollable layout coordinates** translated by the
///    scroll offset such that (0.0, 0.0) is the top left corner of the
///    viewport.
///
///    Because the viewport is centered at the scrollable list's scroll offset
///    instead of starting at the scroll offset, there are paintable children
///    ~1/2 viewport length before and after the scroll offset instead of ~1
///    viewport length after the scroll offset.
///
///    Children's visibility inclusion in the viewport is determined in this
///    system regardless of the cylinder's properties such as [diameterRatio]
///    or [perspective]. In other words, a 100px long viewport will always
///    paint 10-11 visible 10px children if there are enough children in the
///    viewport.
///
/// 3. The **transformed cylindrical space viewport painting coordinates**.
///    Children from system 2 get their positions transformed into a cylindrical
///    projection matrix instead of its cartesian offset with respect to the
///    scroll offset.
///
///    Children in this coordinate system are painted.
///
///    The wheel's size and the maximum and minimum visible angles are both
///    controlled by [diameterRatio]. Children visible in the **untransformed
///    plane's viewport painting coordinates**'s viewport will be radially
///    evenly laid out between the maximum and minimum angles determined by
///    intersecting the viewport's main axis length with a cylinder whose
///    diameter is [diameterRatio] times longer, as long as those angles are
///    between -pi/2 and pi/2.
///
///    For example, if [diameterRatio] is 2.0 and this [RenderCircleListViewport]
///    is 100.0px in the main axis, then the diameter is 200.0. And children
///    will be evenly laid out between that cylinder's -arcsin(1/2) and
///    arcsin(1/2) angles.
///
///    The cylinder's 0 degree side is always centered in the
///    [RenderCircleListViewport]. The transformation from **untransformed
///    plane's viewport painting coordinates** is also done such that the child
///    in the center of that plane will be mostly untransformed with children
///    above and below it being transformed more as the angle increases.
class RenderCircleListViewport extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, CircleListParentData>
    implements RenderAbstractViewport {
  /// Creates a [RenderCircleListViewport] which renders children on a wheel.
  ///
  /// All arguments must not be null. Optional arguments have reasonable defaults.
  RenderCircleListViewport({
    required this.childManager,
    required ViewportOffset offset,
    required double itemExtent,
    required Axis axis,
    double radius = 100,
    bool clipToSize = true,
    bool renderChildrenOutsideViewport = false,
    List<RenderBox>? children,
  })  : assert(itemExtent > 0),
        assert(
          !renderChildrenOutsideViewport || !clipToSize,
          clipToSizeAndRenderChildrenOutsideViewportConflict,
        ),
        _axis = axis,
        _radius = radius,
        _offset = offset,
        _itemExtent = itemExtent,
        _clipToSize = clipToSize,
        _renderChildrenOutsideViewport = renderChildrenOutsideViewport {
    addAll(children);
  }

  /// An error message to show when [clipToSize] and [renderChildrenOutsideViewport]
  /// are set to conflicting values.
  static const String clipToSizeAndRenderChildrenOutsideViewportConflict =
      'Cannot renderChildrenOutsideViewport and clipToSize since children '
      'rendered outside will be clipped anyway.';

  /// The delegate that manages the children of this object.
  final CircleListChildManager childManager;

  /// The associated ViewportOffset object for the viewport describing the part
  /// of the content inside that's visible.
  ///
  /// The [ViewportOffset.pixels] value determines the scroll offset that the
  /// viewport uses to select which part of its content to display. As the user
  /// scrolls the viewport, this value changes, which changes the content that
  /// is displayed.
  ///
  /// Must not be null.
  ViewportOffset get offset => _offset;
  ViewportOffset _offset;
  set offset(ViewportOffset value) {
    if (value == _offset) return;
    if (attached) _offset.removeListener(_hasScrolled);
    _offset = value;
    if (attached) _offset.addListener(_hasScrolled);
    markNeedsLayout();
  }

  /// {@template flutter.rendering.wheelList.itemExtent}
  /// The size of the children along the main axis. Children [RenderBox]es will
  /// be given the [BoxConstraints] of this exact size.
  ///
  /// Must not be null and must be positive.
  /// {@endtemplate}
  double get itemExtent => _itemExtent;
  double _itemExtent;
  set itemExtent(double value) {
    assert(value > 0);
    if (value == _itemExtent) return;
    _itemExtent = value;
    markNeedsLayout();
  }

  /// {@template flutter.rendering.wheelList.clipToSize}
  /// Whether to clip painted children to the inside of this viewport.
  ///
  /// Defaults to [true]. Must not be null.
  ///
  /// If this is false and [renderChildrenOutsideViewport] is false, the
  /// first and last children may be painted partly outside of this scroll view.
  /// {@endtemplate}
  bool get clipToSize => _clipToSize;
  bool _clipToSize;
  set clipToSize(bool value) {
    assert(
      !renderChildrenOutsideViewport || !clipToSize,
      clipToSizeAndRenderChildrenOutsideViewportConflict,
    );
    if (value == _clipToSize) return;
    _clipToSize = value;
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  /// {@template flutter.rendering.wheelList.renderChildrenOutsideViewport}
  /// Whether to paint children inside the viewport only.
  ///
  /// If false, every child will be painted. However the [Scrollable] is still
  /// the size of the viewport and detects gestures inside only.
  ///
  /// Defaults to [false]. Must not be null. Cannot be true if [clipToSize]
  /// is also true since children outside the viewport will be clipped, and
  /// therefore cannot render children outside the viewport.
  /// {@endtemplate}
  bool get renderChildrenOutsideViewport => _renderChildrenOutsideViewport;
  bool _renderChildrenOutsideViewport;
  set renderChildrenOutsideViewport(bool value) {
    assert(
      !renderChildrenOutsideViewport || !clipToSize,
      clipToSizeAndRenderChildrenOutsideViewportConflict,
    );
    if (value == _renderChildrenOutsideViewport) return;
    _renderChildrenOutsideViewport = value;
    markNeedsLayout();
    markNeedsSemanticsUpdate();
  }

  Axis get axis => _axis;
  Axis _axis;
  set axis(Axis value) {
    if (value == _axis) return;
    _axis = value;
    markNeedsLayout();
    markNeedsSemanticsUpdate();
  }

  double get radius => _radius;
  double _radius;
  set radius(double value) {
    assert(value > 0);
    if (value == _radius) return;
    _radius = value;
    markNeedsLayout();
    markNeedsSemanticsUpdate();
  }

  void _hasScrolled() {
    markNeedsLayout();
    markNeedsSemanticsUpdate();
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! CircleListParentData) {
      child.parentData = CircleListParentData();
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _offset.addListener(_hasScrolled);
  }

  @override
  void detach() {
    _offset.removeListener(_hasScrolled);
    super.detach();
  }

  @override
  bool get isRepaintBoundary => true;

  /// Main axis length in the untransformed plane.
  double get _viewportExtent {
    assert(hasSize);
    return axis == Axis.horizontal ? size.width : size.height;
  }

  double get _mainAxisSize {
    return _viewportExtent;
  }

  /// Main axis scroll extent in the **scrollable layout coordinates** that puts
  /// the first item in the center.
  double get _minEstimatedScrollExtent {
    assert(hasSize);
    if (childManager.childCount == null) return double.negativeInfinity;
    return 0.0;
  }

  /// Main axis scroll extent in the **scrollable layout coordinates** that puts
  /// the last item in the center.
  double get _maxEstimatedScrollExtent {
    assert(hasSize);
    if (childManager.childCount == null) return double.infinity;

    return math.max(0.0, (childManager.childCount! - 1) * _itemExtent);
  }

  /// Scroll extent distance in the untransformed plane between the center
  /// position in the viewport and the top position in the viewport.
  ///
  /// It's also the distance in the untransformed plane that children's painting
  /// is offset by with respect to those children's [BoxParentData.offset].
  ///
  double get _scrollMarginExtent {
    assert(hasSize);
    // Consider adding alignment options other than center.
    return -_mainAxisSize / 2.0 + _itemExtent / 2.0;
  }

  /// Transforms a **scrollable layout coordinates**' y position to the
  /// **untransformed plane's viewport painting coordinates**' y position given
  /// the current scroll offset.
  double _getUntransformedPaintingCoordinate(double layoutCoordinate) {
    return layoutCoordinate - _scrollMarginExtent - offset.pixels;
  }

  double _getIntrinsicCrossAxis(_ChildSizingFunction childSize) {
    double extent = 0.0;
    RenderBox? child = firstChild;
    while (child != null) {
      extent = math.max(extent, childSize(child));
      child = childAfter(child);
    }
    return extent;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    if (axis == Axis.horizontal) {
      if (childManager.childCount == null) {
        return 0.0;
      }
      return childManager.childCount! * _itemExtent;
    }

    return _getIntrinsicCrossAxis(
        (RenderBox child) => child.getMinIntrinsicWidth(height));
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    if (axis == Axis.horizontal) {
      if (childManager.childCount == null) {
        return 0.0;
      }
      return childManager.childCount! * _itemExtent;
    }

    return _getIntrinsicCrossAxis(
        (RenderBox child) => child.getMaxIntrinsicWidth(height));
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    if (axis == Axis.vertical) {
      if (childManager.childCount == null) {
        return 0.0;
      }
      return childManager.childCount! * _itemExtent;
    }

    return _getIntrinsicCrossAxis(
        (RenderBox child) => child.getMinIntrinsicHeight(width));
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    if (axis == Axis.vertical) {
      if (childManager.childCount == null) {
        return 0.0;
      }
      return childManager.childCount! * _itemExtent;
    }

    return _getIntrinsicCrossAxis(
        (RenderBox child) => child.getMaxIntrinsicHeight(width));
  }

  @override
  bool get sizedByParent => true;

  @override
  void performResize() {
    size = constraints.biggest;
  }

  /// Gets the index of a child by looking at its parentData.
  int? indexOf(RenderBox child) {
    final CircleListParentData childParentData =
        child.parentData as CircleListParentData;
    assert(childParentData.index != null);
    return childParentData.index;
  }

  /// Returns the index of the child at the given offset.
  int scrollOffsetToIndex(double scrollOffset) =>
      (scrollOffset / itemExtent).floor();

  /// Returns the scroll offset of the child with the given index.
  double indexToScrollOffset(int index) => index * itemExtent;

  void _createChild(int index, {RenderBox? after}) {
    invokeLayoutCallback<BoxConstraints>((BoxConstraints constraints) {
      assert(constraints == this.constraints);
      childManager.createChild(index, after: after);
    });
  }

  void _destroyChild(RenderBox? child) {
    invokeLayoutCallback<BoxConstraints>((BoxConstraints constraints) {
      assert(constraints == this.constraints);
      childManager.removeChild(child);
    });
  }

  void _layoutChild(RenderBox child, BoxConstraints constraints, int index) {
    child.layout(constraints, parentUsesSize: true);
    final CircleListParentData? childParentData =
        child.parentData as CircleListParentData?;
    // Centers the child horizontally.

    if (axis == Axis.horizontal) {
      final double crossPosition = size.height / 2.0 - child.size.height / 2.0;
      childParentData!.offset =
          Offset(indexToScrollOffset(index), crossPosition);
    } else {
      final double crossPosition = size.width / 2.0 - child.size.width / 2.0;
      childParentData!.offset =
          Offset(crossPosition, indexToScrollOffset(index));
    }
  }

  /// Performs layout based on how [childManager] provides children.
  ///
  /// From the current scroll offset, the minimum index and maximum index that
  /// is visible in the viewport can be calculated. The index range of the
  /// currently active children can also be acquired by looking directly at
  /// the current child list. This function has to modify the current index
  /// range to match the target index range by removing children that are no
  /// longer visible and creating those that are visible but not yet provided
  /// by [childManager].
  @override
  void performLayout() {
    final BoxConstraints childConstraints = constraints.copyWith(
      minHeight: _itemExtent,
      maxHeight: _itemExtent,
      minWidth: 0.0,
    );

    // The height, in pixel, that children will be visible and might be laid out
    // and painted.
    double visibleSize = _mainAxisSize;
    // If renderChildrenOutsideViewport is true, we spawn extra children by
    // doubling the visibility range, those that are in the backside of the
    // cylinder won't be painted anyway.
    if (renderChildrenOutsideViewport) visibleSize *= 2;

    final double firstVisibleOffset =
        offset.pixels + _itemExtent / 2 - visibleSize / 2;
    final double lastVisibleOffset = firstVisibleOffset + visibleSize;

    // The index range that we want to spawn children. We find indexes that
    // are in the interval [firstVisibleOffset, lastVisibleOffset).
    int targetFirstIndex = scrollOffsetToIndex(firstVisibleOffset);
    int targetLastIndex = scrollOffsetToIndex(lastVisibleOffset);
    // Because we exclude lastVisibleOffset, if there's a new child starting at
    // that offset, it is removed.
    if (targetLastIndex * _itemExtent == lastVisibleOffset) targetLastIndex--;

    // Validates the target index range.
    while (!childManager.childExistsAt(targetFirstIndex) &&
        targetFirstIndex <= targetLastIndex) {
      targetFirstIndex++;
    }
    while (!childManager.childExistsAt(targetLastIndex) &&
        targetFirstIndex <= targetLastIndex) {
      targetLastIndex--;
    }

    // If it turns out there's no children to layout, we remove old children and
    // return.
    if (targetFirstIndex > targetLastIndex) {
      while (firstChild != null) {
        _destroyChild(firstChild);
      }
      return;
    }

    // Now there are 2 cases:
    //  - The target index range and our current index range have intersection:
    //    We shorten and extend our current child list so that the two lists
    //    match. Most of the time we are in this case.
    //  - The target list and our current child list have no intersection:
    //    We first remove all children and then add one child from the target
    //    list => this case becomes the other case.

    // Case when there is no intersection.
    if (childCount > 0 &&
        (indexOf(firstChild!)! > targetLastIndex ||
            indexOf(lastChild!)! < targetFirstIndex)) {
      while (firstChild != null) {
        _destroyChild(firstChild);
      }
    }

    // If there is no child at this stage, we add the first one that is in
    // target range.
    if (childCount == 0) {
      _createChild(targetFirstIndex);
      _layoutChild(firstChild!, childConstraints, targetFirstIndex);
    }

    int currentFirstIndex = indexOf(firstChild!)!;
    int currentLastIndex = indexOf(lastChild!)!;

    // Remove all unnecessary children by shortening the current child list, in
    // both directions.
    while (currentFirstIndex < targetFirstIndex) {
      _destroyChild(firstChild);
      currentFirstIndex++;
    }
    while (currentLastIndex > targetLastIndex) {
      _destroyChild(lastChild);
      currentLastIndex--;
    }

    // Relayout all active children.
    RenderBox? child = firstChild;
    while (child != null) {
      child.layout(childConstraints, parentUsesSize: true);
      child = childAfter(child);
    }

    // Spawning new children that are actually visible but not in child list yet.
    while (currentFirstIndex > targetFirstIndex) {
      _createChild(currentFirstIndex - 1);
      _layoutChild(firstChild!, childConstraints, --currentFirstIndex);
    }
    while (currentLastIndex < targetLastIndex) {
      _createChild(currentLastIndex + 1, after: lastChild);
      _layoutChild(lastChild!, childConstraints, ++currentLastIndex);
    }

    offset.applyViewportDimension(_viewportExtent);

    // Applying content dimensions bases on how the childManager builds widgets:
    // if it is available to provide a child just out of target range, then
    // we don't know whether there's a limit yet, and set the dimension to the
    // estimated value. Otherwise, we set the dimension limited to our target
    // range.
    final double minScrollExtent =
        childManager.childExistsAt(targetFirstIndex - 1)
            ? _minEstimatedScrollExtent
            : indexToScrollOffset(targetFirstIndex);
    final double maxScrollExtent =
        childManager.childExistsAt(targetLastIndex + 1)
            ? _maxEstimatedScrollExtent
            : indexToScrollOffset(targetLastIndex);
    offset.applyContentDimensions(minScrollExtent, maxScrollExtent);
  }

  bool _shouldClipAtCurrentOffset() {
    final double firsttUntransformedPaint =
        _getUntransformedPaintingCoordinate(0.0);
    return firsttUntransformedPaint < 0.0 ||
        _mainAxisSize <
            firsttUntransformedPaint + _maxEstimatedScrollExtent + _itemExtent;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (childCount > 0) {
      if (_clipToSize && _shouldClipAtCurrentOffset()) {
        context.pushClipRect(
          needsCompositing,
          offset,
          Offset.zero & size,
          _paintVisibleChildren,
        );
      } else {
        _paintVisibleChildren(context, offset);
      }
    }
  }

  /// Paints all children visible in the current viewport.
  void _paintVisibleChildren(PaintingContext context, Offset offset) {
    RenderBox? childToPaint = firstChild;
    CircleListParentData? childParentData =
        childToPaint?.parentData as CircleListParentData?;

    while (childParentData != null) {
      _paintTransformedChild(
          childToPaint, context, offset, childParentData.offset);
      if (childToPaint != null) childToPaint = childAfter(childToPaint);
      childParentData = childToPaint?.parentData as CircleListParentData?;
    }
  }

  /// Takes in a child with a **scrollable layout offset** and paints it in the
  /// **transformed cylindrical space viewport painting coordinates**.
  void _paintTransformedChild(
    RenderBox? child,
    PaintingContext context,
    Offset offset,
    Offset layoutOffset,
  ) {
    final Offset untransformedPaintingCoordinates = offset +
        Offset(
          axis == Axis.vertical
              ? layoutOffset.dx
              : _getUntransformedPaintingCoordinate(layoutOffset.dx),
          axis == Axis.horizontal
              ? layoutOffset.dy
              : _getUntransformedPaintingCoordinate(layoutOffset.dy),
        );

    final mainCordinate = axis == Axis.horizontal
        ? untransformedPaintingCoordinates.dx
        : untransformedPaintingCoordinates.dy;

    final fractional =
        ((_mainAxisSize / 2) - (mainCordinate + _itemExtent / 2.0)) /
            (_mainAxisSize / 2);

    double? angle;

    if (axis == Axis.horizontal) {
      angle = lerpDouble(-math.pi / 2, -math.pi, fractional);
    } else {
      angle = lerpDouble(0, -math.pi / 2, fractional);
    }

    final circleOffset =
        Offset(radius * math.cos(angle!), radius * math.sin(angle));

    final Matrix4 circleTransform = Matrix4.translationValues(
      axis == Axis.vertical ? circleOffset.dx - radius : circleOffset.dx,
      axis == Axis.horizontal ? circleOffset.dy : circleOffset.dy - radius,
      0,
    );

    // Offset that helps painting everything in the center (e.g. angle = 0).
    Offset offsetToCenter;

    if (axis == Axis.horizontal) {
      offsetToCenter = Offset(
        0,
        untransformedPaintingCoordinates.dy + radius,
      );
    } else {
      offsetToCenter = Offset(
        untransformedPaintingCoordinates.dx,
        radius - _scrollMarginExtent,
      );
    }

    _paintChild(context, offset, child, circleTransform, offsetToCenter);
  }

  // / Paint the child cylindrically at given offset.
  void _paintChild(
    PaintingContext context,
    Offset offset,
    RenderBox? child,
    Matrix4 circleTransform,
    Offset offsetToCenter,
  ) {
    context.pushTransform(
      // Text with TransformLayers and no cullRects currently have an issue rendering
      // https://github.com/flutter/flutter/issues/14224.
      false,
      offset,
      circleTransform,
      // Pre-transform painting function.
      (PaintingContext context, Offset offset) {
        context.paintChild(
          child!,
          // Paint everything in the center (e.g. angle = 0), then transform.
          offset + offsetToCenter,
        );
      },
    );
  }

  /// This returns the matrices relative to the **untransformed plane's viewport
  /// painting coordinates** system.
  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    final CircleListParentData? parentData =
        child.parentData as CircleListParentData?;
    if (axis == Axis.vertical) {
      transform.translate(
          0.0, _getUntransformedPaintingCoordinate(parentData!.offset.dy));
    } else {
      transform.translate(
          _getUntransformedPaintingCoordinate(parentData!.offset.dx), 0.0);
    }
  }

  @override
  Rect? describeApproximatePaintClip(RenderObject child) {
    if (_shouldClipAtCurrentOffset()) {
      return Offset.zero & size;
    }
    return null;
  }

  @override
  bool hitTestChildren(HitTestResult result, {Offset? position}) {
    return false;
  }

  @override
  RevealedOffset getOffsetToReveal(RenderObject target, double alignment,
      {Rect? rect, Axis? axis}) {
    // `target` is only fully revealed when in the selected/center position. Therefore,
    // this method always returns the offset that shows `target` in the center position,
    // which is the same offset for all `alignment` values.

    rect ??= target.paintBounds;

    // `child` will be the last RenderObject before the viewport when walking up from `target`.
    RenderObject child = target;
    while (child.parent != this) {
      child = child.parent as RenderObject;
    }

    final CircleListParentData? parentData =
        child.parentData as CircleListParentData?;
    final double targetOffset = axis == Axis.horizontal
        ? parentData!.offset.dx
        : parentData!.offset.dy; // the so-called "centerPosition"

    final Matrix4 transform = target.getTransformTo(this);
    final Rect bounds = MatrixUtils.transformRect(transform, rect);
    final Rect targetRect = bounds.translate(
      axis == Axis.vertical ? 0.0 : (size.width - itemExtent) / 2,
      axis == Axis.horizontal ? 0.0 : (size.height - itemExtent) / 2,
    );

    return RevealedOffset(offset: targetOffset, rect: targetRect);
  }

  @override
  void showOnScreen({
    RenderObject? descendant,
    Rect? rect,
    Duration duration = Duration.zero,
    Curve curve = Curves.ease,
  }) {
    if (descendant != null) {
      // Shows the descendant in the selected/center position.
      final RevealedOffset revealedOffset =
          getOffsetToReveal(descendant, 0.5, rect: rect);
      if (duration == Duration.zero) {
        offset.jumpTo(revealedOffset.offset);
      } else {
        offset.animateTo(revealedOffset.offset,
            duration: duration, curve: curve);
      }
      rect = revealedOffset.rect;
    }

    super.showOnScreen(
      rect: rect,
      duration: duration,
      curve: curve,
    );
  }
}
