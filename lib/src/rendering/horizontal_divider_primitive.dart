// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';

// =============================================================================
// RenderHorizontalDivider - Axis-locked separator engine
// =============================================================================

class HorizontalDividerPrimitive extends SingleChildRenderObjectWidget {
  const HorizontalDividerPrimitive({
    super.key,
    this.height = 16.0,
    this.thickness = 0.0,
    this.indent = 0.0,
    this.endIndent = 0.0,
    this.color,
  });

  final double height;
  final double thickness;
  final double indent;
  final double endIndent;
  final Color? color;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderHorizontalDividerPrimitive(
      height: height,
      thickness: thickness,
      indent: indent,
      endIndent: endIndent,
      color: color ?? const Color(0xFF000000),
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderHorizontalDividerPrimitive renderObject,
  ) {
    renderObject
      ..dividerHeight = height
      ..thickness = thickness
      ..indent = indent
      ..endIndent = endIndent
      ..color = color ?? const Color(0xFF000000);
  }
}

class RenderHorizontalDividerPrimitive extends RenderBox {
  RenderHorizontalDividerPrimitive({
    required double height,
    required double thickness,
    required double indent,
    required double endIndent,
    required Color color,
  }) : _dividerHeight = height,
       _thickness = thickness,
       _indent = indent,
       _endIndent = endIndent,
       _color = color;

  double _dividerHeight;
  double get dividerHeight => _dividerHeight;
  set dividerHeight(double value) {
    if (_dividerHeight != value) {
      _dividerHeight = value;
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
    size = constraints.constrain(Size(constraints.maxWidth, _dividerHeight));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Paint paint = Paint()
      ..color = _color
      ..strokeWidth = _thickness > 0 ? _thickness : 1.0;
    final double y = offset.dy + _dividerHeight / 2;
    context.canvas.drawLine(
      Offset(offset.dx + _indent, y),
      Offset(offset.dx + size.width - _endIndent, y),
      paint,
    );
  }
}
