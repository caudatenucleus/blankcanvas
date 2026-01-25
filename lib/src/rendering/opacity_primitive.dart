// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderOpacity - Alpha-layer composition engine
// =============================================================================

class OpacityPrimitive extends SingleChildRenderObjectWidget {
  const OpacityPrimitive({super.key, required this.opacity, super.child});
  final double opacity;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderOpacityPrimitive(opacity: opacity);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderOpacityPrimitive renderObject,
  ) {
    renderObject.opacity = opacity;
  }
}

class RenderOpacityPrimitive extends RenderProxyBox {
  RenderOpacityPrimitive({double opacity = 1.0, RenderBox? child})
    : _opacity = opacity,
      super(child);

  double _opacity;
  double get opacity => _opacity;
  set opacity(double value) {
    if (_opacity != value) {
      _opacity = value;
      markNeedsPaint();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;
    if (_opacity == 0.0) return;
    if (_opacity == 1.0) {
      context.paintChild(child!, offset);
      return;
    }
    context.pushOpacity(offset, (255 * _opacity).round(), (context, offset) {
      context.paintChild(child!, offset);
    });
  }
}
