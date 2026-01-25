import 'package:flutter/widgets.dart';

/// A gap widget for Row/Column using lowest-level APIs.
class Space extends LeafRenderObjectWidget {
  const Space({super.key, this.width, this.height, this.axis});

  final double? width;
  final double? height;
  final Axis? axis;

  /// Create a horizontal gap
  const Space.horizontal(double extent, {super.key})
    : width = extent,
      height = null,
      axis = Axis.horizontal;

  /// Create a vertical gap
  const Space.vertical(double extent, {super.key})
    : width = null,
      height = extent,
      axis = Axis.vertical;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSpace(width: width, height: height, axis: axis);
  }

  @override
  void updateRenderObject(BuildContext context, RenderSpace renderObject) {
    renderObject
      ..spaceWidth = width
      ..spaceHeight = height
      ..axis = axis;
  }
}

class RenderSpace extends RenderBox {
  RenderSpace({double? width, double? height, Axis? axis})
    : _width = width,
      _height = height,
      _axis = axis;

  double? _width;
  double? get spaceWidth => _width;
  set spaceWidth(double? value) {
    if (_width == value) return;
    _width = value;
    markNeedsLayout();
  }

  double? _height;
  double? get spaceHeight => _height;
  set spaceHeight(double? value) {
    if (_height == value) return;
    _height = value;
    markNeedsLayout();
  }

  Axis? _axis;
  Axis? get axis => _axis;
  set axis(Axis? value) {
    if (_axis == value) return;
    _axis = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    double w = _width ?? 0;
    double h = _height ?? 0;

    // If axis is specified but dimension is not, use flexible sizing
    if (_axis == Axis.horizontal && _width == null) {
      w = constraints.maxWidth.isFinite ? constraints.maxWidth : 0;
    }
    if (_axis == Axis.vertical && _height == null) {
      h = constraints.maxHeight.isFinite ? constraints.maxHeight : 0;
    }

    size = constraints.constrain(Size(w, h));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // Empty - just takes up space
  }
}
