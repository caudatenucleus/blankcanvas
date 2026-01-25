import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

/// A draggable floating bubble widget.
class FloatingBubble extends SingleChildRenderObjectWidget {
  const FloatingBubble({
    super.key,
    super.child,
    this.initialOffset = const Offset(20, 20),
    this.snapToEdge = true,
    this.tag,
  });

  final Offset initialOffset;
  final bool snapToEdge;
  final String? tag;

  @override
  RenderFloatingBubble createRenderObject(BuildContext context) {
    return RenderFloatingBubble(
      initialOffset: initialOffset,
      snapToEdge: snapToEdge,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderFloatingBubble renderObject,
  ) {
    renderObject
      ..initialOffset = initialOffset
      ..snapToEdge = snapToEdge;
  }
}

class RenderFloatingBubble extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  RenderFloatingBubble({
    required Offset initialOffset,
    required bool snapToEdge,
  }) : _currentOffset = initialOffset,
       _snapToEdge = snapToEdge {
    _pan = PanGestureRecognizer()
      ..onUpdate = _handlePanUpdate
      ..onEnd = _handlePanEnd;
  }

  set initialOffset(Offset value) {
    // Only set if we haven't moved yet? Or reset?
    // For now, let's ignore dynamic updates to initialOffset to preserve interaction state.
  }

  bool _snapToEdge;
  set snapToEdge(bool value) {
    _snapToEdge = value;
  }

  late PanGestureRecognizer _pan;
  Offset _currentOffset;

  @override
  void detach() {
    _pan.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    // Fill availability
    size = constraints.biggest;

    if (child != null) {
      child!.layout(BoxConstraints.loose(size), parentUsesSize: true);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      final childParentData = child!.parentData as BoxParentData;
      childParentData.offset =
          _currentOffset; // Update parent data for hit testing
      context.paintChild(child!, _currentOffset + offset);
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    // Clamp to screen
    final childSize = child?.size ?? Size.zero;
    final maxX = size.width - childSize.width;
    final maxY = size.height - childSize.height;

    _currentOffset += details.delta;

    // Clamp immediately
    double x = _currentOffset.dx.clamp(0.0, maxX);
    double y = _currentOffset.dy.clamp(0.0, maxY);

    _currentOffset = Offset(x, y);
    markNeedsPaint();
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_snapToEdge && child != null) {
      final childSize = child!.size;
      final centerX = _currentOffset.dx + childSize.width / 2;
      final screenCenterX = size.width / 2;

      double targetX;
      if (centerX < screenCenterX) {
        targetX = 0;
      } else {
        targetX = size.width - childSize.width;
      }

      // Simple snap (no animation for now in lowest-level API without ticker)
      _currentOffset = Offset(targetX, _currentOffset.dy);
      markNeedsPaint();
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    if (child != null) {
      // The child is at _currentOffset relative to us.
      // 'position' is relative to us.
      // So checks if position is inside child's rect.

      final bool jhit = result.addWithPaintOffset(
        offset: _currentOffset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          return child!.hitTest(result, position: transformed);
        },
      );

      return jhit;
    }
    return false;
  }

  @override
  bool hitTestSelf(Offset position) {
    // Only hit if child isn't hit? Or allow dragging from empty space?
    // Usually floating bubble only catches hits on itself.
    // Since hitTestChildren is called first by default in RenderBox (actually it deals with z-order),
    // we want to claim the hit if it hits the child bubble.
    // However, the standard behavior is `hitTest` -> `hitTestChildren` || `hitTestSelf`.
    // We want to return true ONLY if the point is within our child's bounds, so the pan recognizer gets it.

    // But wait, if hitTestChildren returns true, `hitTest` returns true.
    // handleEvent receives the event.

    // Wait, RenderBox.hitTest handles adding the entry.
    // We just need to make sure `handleEvent` is called.
    return false;
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    // Forward to child?
    // No, we want to handle dragging.
    if (event is PointerDownEvent) {
      _pan.addPointer(event);
    }
  }
}
