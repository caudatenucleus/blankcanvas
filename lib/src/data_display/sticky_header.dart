import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'dart:math' as math;

/// A sticky header using RenderSliver implementation directly.
class StickyHeader extends SingleChildRenderObjectWidget {
  const StickyHeader({
    super.key,
    required Widget child,
    this.minHeight = 50.0,
    this.maxHeight = 50.0,
  }) : super(child: child);

  final double minHeight;
  final double maxHeight;

  @override
  RenderSliver createRenderObject(BuildContext context) {
    return RenderStickyHeader(minHeight: minHeight, maxHeight: maxHeight);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderStickyHeader renderObject,
  ) {
    renderObject
      ..minHeight = minHeight
      ..maxHeight = maxHeight;
  }
}

class RenderStickyHeader extends RenderSliver
    with RenderObjectWithChildMixin<RenderBox> {
  RenderStickyHeader({required double minHeight, required double maxHeight})
    : _minHeight = minHeight,
      _maxHeight = maxHeight;

  double _minHeight;
  double get minHeight => _minHeight;
  set minHeight(double value) {
    if (_minHeight == value) return;
    _minHeight = value;
    markNeedsLayout();
  }

  double _maxHeight;
  double get maxHeight => _maxHeight;
  set maxHeight(double value) {
    if (_maxHeight == value) return;
    _maxHeight = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! SliverPhysicalParentData) {
      child.parentData = SliverPhysicalParentData();
    }
  }

  @override
  void performLayout() {
    final SliverConstraints constraints = this.constraints;
    final double maxExtent = _maxHeight;

    // Pinned behavior logic:
    // paintExtent: The amount of vertical space we occupy on screen (visible height).
    // layoutExtent: The amount of scroll space we consume.

    // As we scroll down (scrollOffset increases):
    // We want to remain visible at the top.
    // So paintExtent is usually maxExtent (clamped by viewport/remaining).
    // layoutExtent decreases so content below slides UP under us.

    final double visibleExtent = math.min(
      maxExtent,
      constraints.remainingPaintExtent,
    );
    final double layoutExtent = math.max(
      0.0,
      maxExtent - constraints.scrollOffset,
    );

    if (child != null) {
      child!.layout(
        constraints.asBoxConstraints(
          minExtent: visibleExtent,
          maxExtent: visibleExtent, // Force child to be visible size
        ),
        parentUsesSize: true,
      );
    }

    geometry = SliverGeometry(
      scrollExtent: maxExtent,
      paintExtent: visibleExtent,
      layoutExtent: layoutExtent,
      maxPaintExtent: maxExtent,
      hasVisualOverflow: true,
      paintOrigin: 0.0,
    );

    if (child != null) {
      final SliverPhysicalParentData childParentData =
          child!.parentData! as SliverPhysicalParentData;
      // Pinning logic: Shift child so it appears stationary in viewport
      switch (constraints.axisDirection) {
        case AxisDirection.down:
          childParentData.paintOffset = Offset(0.0, constraints.scrollOffset);
          break;
        case AxisDirection.up:
          childParentData.paintOffset = Offset(0.0, -constraints.scrollOffset);
          break;
        case AxisDirection.right:
          childParentData.paintOffset = Offset(constraints.scrollOffset, 0.0);
          break;
        case AxisDirection.left:
          childParentData.paintOffset = Offset(-constraints.scrollOffset, 0.0);
          break;
      }
    }
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    final SliverPhysicalParentData childParentData =
        child.parentData! as SliverPhysicalParentData;
    childParentData.applyPaintTransform(transform);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null && geometry!.visible) {
      final SliverPhysicalParentData childParentData =
          child!.parentData! as SliverPhysicalParentData;
      context.paintChild(child!, offset + childParentData.paintOffset);
    }
  }

  @override
  bool hitTestChildren(
    SliverHitTestResult result, {
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) {
    if (child != null) {
      return child!.hitTest(
        BoxHitTestResult.wrap(result),
        position: Offset(crossAxisPosition, mainAxisPosition),
      );
    }
    return false;
  }
}
