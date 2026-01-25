import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

/// A layout widget that splits two children with a resizable divider.
class Splitter extends MultiChildRenderObjectWidget {
  Splitter({
    super.key,
    required Widget first,
    required Widget second,
    this.initialRatio = 0.5,
    this.axis = Axis.horizontal,
    this.dividerThickness = 8.0,
    this.dividerColor = const Color(0xFFE0E0E0),
  }) : super(children: [first, second]);

  final double initialRatio;
  final Axis axis;
  final double dividerThickness;
  final Color dividerColor;

  @override
  RenderSplitter createRenderObject(BuildContext context) {
    return RenderSplitter(
      initialRatio: initialRatio,
      axis: axis,
      dividerThickness: dividerThickness,
      dividerColor: dividerColor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderSplitter renderObject) {
    renderObject
      ..axis = axis
      ..dividerThickness = dividerThickness
      ..dividerColor = dividerColor;
  }
}

class SplitterParentData extends ContainerBoxParentData<RenderBox> {}

class RenderSplitter extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, SplitterParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, SplitterParentData> {
  RenderSplitter({
    double initialRatio = 0.5,
    Axis axis = Axis.horizontal,
    double dividerThickness = 8.0,
    Color dividerColor = const Color(0xFFE0E0E0),
  }) : _ratio = initialRatio,
       _axis = axis,
       _dividerThickness = dividerThickness,
       _dividerColor = dividerColor {
    // Gestures
    _drag = PanGestureRecognizer()
      ..onUpdate = _handleDragUpdate
      ..onEnd = _handleDragEnd;
  }

  double _ratio;
  Axis _axis;
  double _dividerThickness;
  Color _dividerColor;
  late PanGestureRecognizer _drag;

  // Setters...
  set axis(Axis v) {
    if (_axis != v) {
      _axis = v;
      markNeedsLayout();
    }
  }

  set dividerThickness(double v) {
    if (_dividerThickness != v) {
      _dividerThickness = v;
      markNeedsLayout();
    }
  }

  set dividerColor(Color v) {
    if (_dividerColor != v) {
      _dividerColor = v;
      markNeedsPaint();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! SplitterParentData) {
      child.parentData = SplitterParentData();
    }
  }

  // Hit testing
  @override
  bool hitTestSelf(Offset position) {
    // Only hit test self if on the divider
    return _dividerRect.contains(position);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void handleEvent(PointerEvent event, covariant HitTestEntry entry) {
    if (event is PointerDownEvent) {
      _drag.addPointer(event);
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final double delta = _axis == Axis.horizontal
        ? details.delta.dx
        : details.delta.dy;
    final double size = _axis == Axis.horizontal
        ? this.size.width
        : this.size.height;

    // Convert delta pixels to ratio change
    final double ratioDelta = delta / (size - _dividerThickness);
    _ratio = (_ratio + ratioDelta).clamp(
      0.1,
      0.9,
    ); // Clamp to avoid disappearing children
    markNeedsLayout();
  }

  void _handleDragEnd(DragEndDetails details) {
    // Snap? No, just stop.
  }

  late Rect _dividerRect;

  @override
  void performLayout() {
    if (childCount != 2) {
      size = constraints.biggest;
      return;
    }

    final RenderBox? child1 = firstChild;
    if (child1 == null) {
      size = constraints.biggest;
      return;
    }
    final RenderBox? child2 = childAfter(child1);
    if (child2 == null) {
      size = constraints.biggest;
      return;
    }

    final double totalSize = _axis == Axis.horizontal
        ? constraints.maxWidth
        : constraints.maxHeight;
    final double availableSpace = totalSize - _dividerThickness;
    final double size1 = availableSpace * _ratio;
    final double size2 = availableSpace - size1;

    BoxConstraints childConstraints;
    if (_axis == Axis.horizontal) {
      childConstraints = BoxConstraints(
        minWidth: size1,
        maxWidth: size1,
        minHeight: constraints.maxHeight,
        maxHeight: constraints.maxHeight,
      );
      child1.layout(childConstraints, parentUsesSize: true);

      childConstraints = BoxConstraints(
        minWidth: size2,
        maxWidth: size2,
        minHeight: constraints.maxHeight,
        maxHeight: constraints.maxHeight,
      );
      child2.layout(childConstraints, parentUsesSize: true);

      // Position
      final SplitterParentData pd1 = child1.parentData as SplitterParentData;
      pd1.offset = Offset.zero;

      final SplitterParentData pd2 = child2.parentData as SplitterParentData;
      pd2.offset = Offset(size1 + _dividerThickness, 0);

      _dividerRect = Rect.fromLTWH(
        size1,
        0,
        _dividerThickness,
        constraints.maxHeight,
      );
    } else {
      childConstraints = BoxConstraints(
        minWidth: constraints.maxWidth,
        maxWidth: constraints.maxWidth,
        minHeight: size1,
        maxHeight: size1,
      );
      child1.layout(childConstraints, parentUsesSize: true);

      childConstraints = BoxConstraints(
        minWidth: constraints.maxWidth,
        maxWidth: constraints.maxWidth,
        minHeight: size2,
        maxHeight: size2,
      );
      child2.layout(childConstraints, parentUsesSize: true);

      // Position
      final SplitterParentData pd1 = child1.parentData as SplitterParentData;
      pd1.offset = Offset.zero;

      final SplitterParentData pd2 = child2.parentData as SplitterParentData;
      pd2.offset = Offset(0, size1 + _dividerThickness);

      _dividerRect = Rect.fromLTWH(
        0,
        size1,
        constraints.maxWidth,
        _dividerThickness,
      );
    }

    size = constraints.biggest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);

    // Paint divider
    final Paint paint = Paint()..color = _dividerColor;
    context.canvas.drawRect(_dividerRect.shift(offset), paint);
  }
}

class SimpleSplitter extends MultiChildRenderObjectWidget {
  SimpleSplitter({
    super.key,
    required Widget first,
    required Widget second,
    double initialRatio = 0.5,
    this.axis = Axis.horizontal,
    this.dividerThickness = 8.0,
    this.dividerColor = const Color(0xFFE0E0E0),
  }) : startRatio = initialRatio,
       super(children: [first, second]);

  final double startRatio;
  final Axis axis;
  final double dividerThickness;
  final Color dividerColor;

  @override
  RenderSplitter createRenderObject(BuildContext context) {
    return RenderSplitter(
      initialRatio: startRatio,
      axis: axis,
      dividerThickness: dividerThickness,
      dividerColor: dividerColor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderSplitter renderObject) {
    renderObject
      ..axis = axis
      ..dividerThickness = dividerThickness
      ..dividerColor = dividerColor;
  }
}
