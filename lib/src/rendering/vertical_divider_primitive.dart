// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';

// =============================================================================
// RenderVerticalDivider - Axis-locked separator engine
// =============================================================================

class VerticalDividerPrimitive extends SingleChildRenderObjectWidget {
  const VerticalDividerPrimitive({
    super.key,
    this.width = 16.0,
    this.thickness = 0.0,
    this.indent = 0.0,
    this.endIndent = 0.0,
    this.color,
  });

  final double width;
  final double thickness;
  final double indent;
  final double endIndent;
  final Color? color;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderVerticalDividerPrimitive(
      width: width,
      thickness: thickness,
      indent: indent,
      endIndent: endIndent,
      color: color ?? const Color(0xFF000000),
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderVerticalDividerPrimitive renderObject,
  ) {
    renderObject
      ..dividerWidth = width
      ..thickness = thickness
      ..indent = indent
      ..endIndent = endIndent
      ..color = color ?? const Color(0xFF000000);
  }
}

class RenderVerticalDividerPrimitive extends RenderBox {
  RenderVerticalDividerPrimitive({
    required double width,
    required double thickness,
    required double indent,
    required double endIndent,
    required Color color,
  }) : _dividerWidth = width,
       _thickness = thickness,
       _indent = indent,
       _endIndent = endIndent,
       _color = color;

  double _dividerWidth;
  double get dividerWidth => _dividerWidth;
  set dividerWidth(double value) {
    if (_dividerWidth != value) {
      _dividerWidth = value;
      markNeedsLayout();
    }
  }

  double _thickness;
  double get thickness => _thickness;
  set thickness(double value) {
    if (_thickness != value) {
      _thickness = value;
      markNeedsPaint();
    }
  }

  double _indent;
  double get indent => _indent;
  set indent(double value) {
    if (_indent != value) {
      _indent = value;
      markNeedsPaint();
    }
  }

  double _endIndent;
  double get endIndent => _endIndent;
  set endIndent(double value) {
    if (_endIndent != value) {
      _endIndent = value;
      markNeedsPaint();
    }
  }

  Color _color;
  Color get color => _color;
  set color(Color value) {
    if (_color != value) {
      _color = value;
      markNeedsPaint();
    }
  }

  @override
  void performLayout() {
    size = constraints.constrain(Size(_dividerWidth, constraints.maxHeight));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Paint paint = Paint()
      ..color = _color
      ..strokeWidth = _thickness > 0 ? _thickness : 1.0;
    final double x = offset.dx + _dividerWidth / 2;
    context.canvas.drawLine(
      Offset(x, offset.dy + _indent),
      Offset(x, offset.dy + size.height - _endIndent),
      paint,
    );
  }
}
