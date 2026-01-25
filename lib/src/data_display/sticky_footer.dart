import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// A footer that sticks to the bottom of a scroll view or screen.
/// This is a RenderSliver implementation for use in CustomScrollView.
class StickyFooter extends SingleChildRenderObjectWidget {
  const StickyFooter({
    super.key,
    required Widget child,
    this.backgroundColor,
    this.tag,
  }) : super(child: child);

  final Color? backgroundColor;
  final String? tag;

  @override
  RenderStickyFooter createRenderObject(BuildContext context) {
    return RenderStickyFooter(backgroundColor: backgroundColor);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderStickyFooter renderObject,
  ) {
    renderObject.backgroundColor = backgroundColor;
  }
}

class RenderStickyFooter extends RenderSliverSingleBoxAdapter {
  RenderStickyFooter({Color? backgroundColor, RenderBox? child})
    : _backgroundColor = backgroundColor {
    this.child = child;
  }

  Color? _backgroundColor;
  set backgroundColor(Color? value) {
    if (_backgroundColor != value) {
      _backgroundColor = value;
      markNeedsPaint();
    }
  }

  @override
  void performLayout() {
    if (child == null) {
      geometry = SliverGeometry.zero;
      return;
    }
    child!.layout(constraints.asBoxConstraints(), parentUsesSize: true);
    final double childExtent = child!.size.height;
    final double paintedChildExtent = calculatePaintOffset(
      constraints,
      from: 0.0,
      to: childExtent,
    );
    final double cacheExtent = calculateCacheOffset(
      constraints,
      from: 0.0,
      to: childExtent,
    );

    assert(paintedChildExtent.isFinite);
    assert(paintedChildExtent >= 0.0);

    // To make it "sticky" at the bottom if the content is small,
    // we need to adjust paintOrigin or scrollOffset.
    // But for now, let's just make it a standard sliver that fills remaining space if needed.

    double layoutExtent = childExtent;
    // If it's a footer, it should probably only take as much space as it needs,
    // unless it wants to push to the bottom.

    geometry = SliverGeometry(
      scrollExtent: childExtent,
      paintExtent: paintedChildExtent,
      cacheExtent: cacheExtent,
      maxPaintExtent: childExtent,
      hitTestExtent: paintedChildExtent,
      hasVisualOverflow:
          childExtent > constraints.remainingPaintExtent ||
          constraints.scrollOffset > 0.0,
    );
    setChildParentData(child!, constraints, geometry!);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null && geometry!.visible) {
      if (_backgroundColor != null) {
        context.canvas.drawRect(
          offset & child!.size,
          Paint()..color = _backgroundColor!,
        );
      }
      context.paintChild(child!, offset);
    }
  }
}
