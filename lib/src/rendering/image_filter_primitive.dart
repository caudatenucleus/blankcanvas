// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui' as ui;

// =============================================================================
// RenderImageFilter - Pixel-primitive filter engine
// =============================================================================

class ImageFilterPrimitive extends SingleChildRenderObjectWidget {
  const ImageFilterPrimitive({super.key, required this.filter, super.child});
  final ui.ImageFilter filter;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderImageFilterPrimitive(filter: filter);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderImageFilterPrimitive renderObject,
  ) {
    renderObject.filter = filter;
  }
}

class RenderImageFilterPrimitive extends RenderProxyBox {
  RenderImageFilterPrimitive({required ui.ImageFilter filter, RenderBox? child})
    : _filter = filter,
      super(child);

  ui.ImageFilter _filter;
  ui.ImageFilter get filter => _filter;
  set filter(ui.ImageFilter value) {
    if (_filter != value) {
      _filter = value;
      markNeedsPaint();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;
    context.canvas.saveLayer(offset & size, Paint()..imageFilter = _filter);
    context.paintChild(child!, offset);
    context.canvas.restore();
  }
}
