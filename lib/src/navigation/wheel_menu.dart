import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

/// A rotatable wheel menu with 3D perspective.
class WheelMenu extends MultiChildRenderObjectWidget {
  const WheelMenu({
    super.key,
    required super.children,
    required this.onSelectedItemChanged,
    this.itemHeight = 48.0,
    this.diameterRatio = 1.5,
    this.tag,
  });

  final ValueChanged<int> onSelectedItemChanged;
  final double itemHeight;
  final double diameterRatio;
  final String? tag;

  @override
  RenderWheelMenu createRenderObject(BuildContext context) {
    return RenderWheelMenu(
      onSelectedItemChanged: onSelectedItemChanged,
      itemHeight: itemHeight,
      diameterRatio: diameterRatio,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderWheelMenu renderObject) {
    renderObject
      ..onSelectedItemChanged = onSelectedItemChanged
      ..itemHeight = itemHeight
      ..diameterRatio = diameterRatio;
  }
}

class _WheelMenuParentData extends ContainerBoxParentData<RenderBox> {}

class RenderWheelMenu extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _WheelMenuParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _WheelMenuParentData> {
  RenderWheelMenu({
    required ValueChanged<int> onSelectedItemChanged,
    required double itemHeight,
    required double diameterRatio,
  }) : _onSelectedItemChanged = onSelectedItemChanged,
       _itemHeight = itemHeight,
       _diameterRatio = diameterRatio {
    _drag = PanGestureRecognizer()
      ..onStart = _handleDragStart
      ..onUpdate = _handleDragUpdate
      ..onEnd = _handleDragEnd;
  }

  ValueChanged<int> _onSelectedItemChanged;
  set onSelectedItemChanged(ValueChanged<int> value) {
    _onSelectedItemChanged = value;
  }

  double _itemHeight;
  set itemHeight(double value) {
    if (_itemHeight != value) {
      _itemHeight = value;
      markNeedsLayout();
    }
  }

  double _diameterRatio;
  set diameterRatio(double value) {
    if (_diameterRatio != value) {
      _diameterRatio = value;
      markNeedsPaint();
    }
  }

  late PanGestureRecognizer _drag;
  double _scrollOffset = 0.0;
  int _selectedIndex = 0;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _WheelMenuParentData) {
      child.parentData = _WheelMenuParentData();
    }
  }

  @override
  void detach() {
    _drag.dispose();
    super.detach();
  }

  void _handleDragStart(DragStartDetails details) {}

  void _handleDragUpdate(DragUpdateDetails details) {
    _scrollOffset -= details.delta.dy;
    // Clamp or Loop? Let's Clamp for now.
    final maxOffset = (childCount - 1) * _itemHeight;
    _scrollOffset = _scrollOffset.clamp(0.0, maxOffset);

    // Update selected index
    final newIndex = (_scrollOffset / _itemHeight).round();
    if (newIndex != _selectedIndex) {
      _selectedIndex = newIndex;
      _onSelectedItemChanged(_selectedIndex);
    }

    markNeedsPaint();
  }

  void _handleDragEnd(DragEndDetails details) {
    // Snap to nearest
    final targetIndex = (_scrollOffset / _itemHeight).round();
    _scrollOffset = targetIndex * _itemHeight;
    markNeedsPaint();
  }

  @override
  void performLayout() {
    // Width = max child width
    // Height = provided from constraints or fixed default?
    // Let's take all constraint height.

    double maxWidth = 0;
    RenderBox? child = firstChild;
    while (child != null) {
      child.layout(
        BoxConstraints(
          minWidth: 0,
          maxWidth: constraints.maxWidth,
          minHeight: _itemHeight,
          maxHeight: _itemHeight,
        ),
        parentUsesSize: true,
      );
      maxWidth = math.max(maxWidth, child.size.width);
      child = childAfter(child);
    }

    size = constraints.constrain(Size(maxWidth, constraints.maxHeight));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // Clip to bounds
    context.pushClipRect(
      needsCompositing,
      offset,
      Offset.zero & size,
      _paintChildren,
    );
  }

  void _paintChildren(PaintingContext context, Offset offset) {
    final center = size.height / 2;
    final cylinderRadius = (size.height * _diameterRatio) / 2;

    RenderBox? child = firstChild;
    int index = 0;

    while (child != null) {
      final childCenterOffset = (index * _itemHeight) - _scrollOffset;
      final distanceToCenter = center - (size.height / 2 + childCenterOffset);

      // Calculate angle
      // Arc length = childCenterOffset
      // Angle = Arc / Radius
      // This is rough approximation for visual effect

      // Simple perspective:
      // y = center + radius * sin(angle)
      // z = radius * cos(angle)
      // scale = perspective / (perspective + z)

      // Simplified: Just y and scale based on distance
      // If item is too far, don't paint

      if (childCenterOffset.abs() < size.height / 2 + _itemHeight) {
        final relativePosition =
            childCenterOffset / (size.height / 2); // -1 to 1 (approx)
        final angle = relativePosition * 1.5; // limit view angle

        if (angle.abs() < math.pi / 2) {
          final y =
              center + math.sin(angle) * (size.height / 2.5); // flatten a bit
          final z = math.cos(angle);
          final scale = z * z; // simple scale falloff
          final opacity = z.clamp(0.0, 1.0);

          final childOffset = Offset(
            offset.dx +
                (size.width - child.size.width) / 2, // Center horizontally
            offset.dy + y - child.size.height / 2,
          );

          context.pushOpacity(offset, (opacity * 255).toInt(), (
            context,
            offset,
          ) {
            context.pushTransform(
              needsCompositing,
              offset,
              Matrix4.identity()..scale(Vector3(scale, scale, 1.0)),
              (context, offset) {
                context.paintChild(child!, childOffset);
              },
            );
          });
        }
      }

      child = childAfter(child);
      index++;
    }
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _drag.addPointer(event);
    }
  }
}
