// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderPhysicalModel - Shadow/Elevation rendering engine
// =============================================================================

class PhysicalModelPrimitive extends SingleChildRenderObjectWidget {
  const PhysicalModelPrimitive({
    super.key,
    this.color = const Color(0xFFFFFFFF),
    this.shadowColor = const Color(0xFF000000),
    this.elevation = 0.0,
    this.borderRadius = BorderRadius.zero,
    super.child,
  });
  final Color color;
  final Color shadowColor;
  final double elevation;
  final BorderRadius borderRadius;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderPhysicalModelPrimitive(
      color: color,
      shadowColor: shadowColor,
      elevation: elevation,
      borderRadius: borderRadius,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderPhysicalModelPrimitive renderObject,
  ) {
    renderObject
      ..color = color
      ..shadowColor = shadowColor
      ..elevation = elevation
      ..borderRadius = borderRadius;
  }
}

class RenderPhysicalModelPrimitive extends RenderProxyBox {
  RenderPhysicalModelPrimitive({
    Color color = const Color(0xFFFFFFFF),
    Color shadowColor = const Color(0xFF000000),
    double elevation = 0.0,
    BorderRadius borderRadius = BorderRadius.zero,
    RenderBox? child,
  }) : _color = color,
       _shadowColor = shadowColor,
       _elevation = elevation,
       _borderRadius = borderRadius,
       super(child);

  Color _color;
  Color get color => _color;
  set color(Color value) {
    if (_color != value) {
      _color = value;
      markNeedsPaint();
    }
  }

  Color _shadowColor;
  Color get shadowColor => _shadowColor;
  set shadowColor(Color value) {
    if (_shadowColor != value) {
      _shadowColor = value;
      markNeedsPaint();
    }
  }

  double _elevation;
  double get elevation => _elevation;
  set elevation(double value) {
    if (_elevation != value) {
      _elevation = value;
      markNeedsPaint();
    }
  }

  BorderRadius _borderRadius;
  BorderRadius get borderRadius => _borderRadius;
  set borderRadius(BorderRadius value) {
    if (_borderRadius != value) {
      _borderRadius = value;
      markNeedsPaint();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final RRect rrect = _borderRadius.toRRect(offset & size);

    // Draw shadow
    if (_elevation > 0) {
      final Path path = Path()..addRRect(rrect);
      canvas.drawShadow(path, _shadowColor, _elevation, true);
    }

    // Draw background
    canvas.drawRRect(rrect, Paint()..color = _color);

    // Paint child on top
    if (child != null) {
      context.paintChild(child!, offset);
    }
  }
}
