// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderColoredBox - Solid color background engine
// =============================================================================

class ColoredBoxPrimitive extends SingleChildRenderObjectWidget {
  const ColoredBoxPrimitive({super.key, required this.color, super.child});
  final Color color;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderColoredBoxPrimitive(color: color);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderColoredBoxPrimitive renderObject,
  ) {
    renderObject.color = color;
  }
}

class RenderColoredBoxPrimitive extends RenderProxyBoxWithHitTestBehavior {
  RenderColoredBoxPrimitive({required Color color, super.child})
    : _color = color,
      super(behavior: HitTestBehavior.opaque);

  Color _color;
  Color get color => _color;
  set color(Color value) {
    if (_color != value) {
      _color = value;
      markNeedsPaint();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.canvas.drawRect(offset & size, Paint()..color = _color);
    if (child != null) {
      context.paintChild(child!, offset);
    }
  }
}
