// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderColorFilter - Matrix-based color transform engine
// =============================================================================

class ColorFilterPrimitive extends SingleChildRenderObjectWidget {
  const ColorFilterPrimitive({
    super.key,
    required this.colorFilter,
    super.child,
  });
  final ColorFilter colorFilter;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderColorFilterPrimitive(colorFilter: colorFilter);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderColorFilterPrimitive renderObject,
  ) {
    renderObject.colorFilter = colorFilter;
  }
}

class RenderColorFilterPrimitive extends RenderProxyBox {
  RenderColorFilterPrimitive({
    required ColorFilter colorFilter,
    RenderBox? child,
  }) : _colorFilter = colorFilter,
       super(child);

  ColorFilter _colorFilter;
  ColorFilter get colorFilter => _colorFilter;
  set colorFilter(ColorFilter value) {
    if (_colorFilter != value) {
      _colorFilter = value;
      markNeedsPaint();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;
    context.canvas.saveLayer(
      offset & size,
      Paint()..colorFilter = _colorFilter,
    );
    context.paintChild(child!, offset);
    context.canvas.restore();
  }
}
