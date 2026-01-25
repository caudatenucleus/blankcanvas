import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

/// A list that scrolls with a 3D cylindrical effect, implemented at the RenderObject level.
class Scroll3D extends MultiChildRenderObjectWidget {
  const Scroll3D({super.key, required super.children, this.itemExtent = 50.0});

  final double itemExtent;

  @override
  RenderScroll3D createRenderObject(BuildContext context) {
    return RenderScroll3D(itemExtent: itemExtent);
  }

  @override
  void updateRenderObject(BuildContext context, RenderScroll3D renderObject) {
    renderObject.itemExtent = itemExtent;
  }
}

class Scroll3DParentData extends ContainerBoxParentData<RenderBox> {}

class RenderScroll3D extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, Scroll3DParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, Scroll3DParentData> {
  RenderScroll3D({required double itemExtent}) : _itemExtent = itemExtent {
    _drag = VerticalDragGestureRecognizer()
      ..onStart = (_) {}
      ..onUpdate = _handleDragUpdate
      ..onEnd = (_) {};
  }

  double _itemExtent;
  set itemExtent(double value) {
    if (_itemExtent != value) {
      _itemExtent = value;
      markNeedsLayout();
    }
  }

  late VerticalDragGestureRecognizer _drag;
  double _scrollOffset = 0.0;

  void _handleDragUpdate(DragUpdateDetails details) {
    _scrollOffset -= details.delta.dy;
    markNeedsPaint();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! Scroll3DParentData) {
      child.parentData = Scroll3DParentData();
    }
  }

  @override
  void performLayout() {
    double maxWidth = 0;

    // We constrain children to the itemExtent
    final childConstraints = BoxConstraints(
      minWidth: 0,
      maxWidth: constraints.maxWidth,
      minHeight: _itemExtent,
      maxHeight: _itemExtent,
    );

    RenderBox? child = firstChild;
    int index = 0;
    while (child != null) {
      child.layout(childConstraints, parentUsesSize: true);
      maxWidth = math.max(maxWidth, child.size.width);

      // Set initial offset to top-down list position?
      // Or set to (0,0) and handle everything in paint?
      // Since we want hit-testing to work somewhat naturally for test finders,
      // let's set it to the "list" position if scrollOffset was 0.
      final Scroll3DParentData pd = child.parentData as Scroll3DParentData;
      pd.offset = Offset(
        (constraints.maxWidth - child.size.width) / 2, // Centered horizontally
        index * _itemExtent, // Vertical list position
      );

      child = childAfter(child);
      index++;
    }
    size = constraints.constrain(Size(maxWidth, constraints.maxHeight));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // We must handle clipping
    context.pushClipRect(
      needsCompositing,
      offset,
      Offset.zero & size,
      _paintChildren,
    );
  }

  void _paintChildren(PaintingContext context, Offset offset) {
    final centerY = size.height / 2;
    RenderBox? child = firstChild;
    int index = 0;

    while (child != null) {
      final Scroll3DParentData pd = child.parentData as Scroll3DParentData;
      final visibleY = (index * _itemExtent) - _scrollOffset;

      // Only paint if visible
      if (visibleY + _itemExtent > 0 && visibleY < size.height) {
        final relativeY = (visibleY + _itemExtent / 2) - centerY;
        final z = 1.0 - (relativeY.abs() * 0.001);
        final opacity = z.clamp(0.2, 1.0);

        final childPaintOffset = Offset(
          pd.offset.dx, // Use laid out X
          visibleY, // Use dynamic Y
        );

        context.pushOpacity(offset, (opacity * 255).toInt(), (ctx, off) {
          // We ignore pd.offset.dy and use visibleY.
          // This means Finder might find it at pd.offset.dy (logical), but we paint at visibleY.
          // This discrepancy usually causes hit test issues if logic != visual.
          // But verify logic below.
          ctx.paintChild(child!, off + childPaintOffset);
        });
      }

      child = childAfter(child);
      index++;
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    // We should hit test using the VISIBLE positions.
    // Iterate all children, calculate their visible rect, test.

    // Default hitTestChildren uses pd.offset.
    // Our pd.offset.dy is static (index * extent).
    // Our visual position is dynamic (index * extent - scrollOffset).
    // So we must manually hit test like Deck.

    RenderBox? child =
        lastChild; // Hit test top-most first (z-order)? here it's 3D list.
    // Usually start from last child?
    int index = childCount - 1;

    while (child != null) {
      final Scroll3DParentData pd = child.parentData as Scroll3DParentData;
      final visibleY = (index * _itemExtent) - _scrollOffset;

      if (visibleY + _itemExtent > 0 && visibleY < size.height) {
        final childOffset = Offset(pd.offset.dx, visibleY);

        final bool isHit = result.addWithPaintOffset(
          offset: childOffset,
          position: position,
          hitTest: (BoxHitTestResult result, Offset transformed) {
            return child!.hitTest(result, position: transformed);
          },
        );
        if (isHit) return true;
      }

      child = pd.previousSibling;
      index--;
    }
    return false;
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _drag.addPointer(event);
    }
  }

  @override
  void detach() {
    _drag.dispose();
    super.detach();
  }
}
