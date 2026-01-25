// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// Generic object inspector container using lowest-level RenderObject APIs.
class InspectorView extends SingleChildRenderObjectWidget {
  const InspectorView({
    super.key,
    required super.child,
    this.backgroundColor = const Color(0xFFF9F9F9),
  });

  final Color backgroundColor;

  @override
  RenderInspectorView createRenderObject(BuildContext context) {
    return RenderInspectorView(backgroundColor: backgroundColor);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderInspectorView renderObject,
  ) {
    renderObject.backgroundColor = backgroundColor;
  }
}

class RenderInspectorView extends RenderProxyBox {
  RenderInspectorView({required Color backgroundColor})
    : _backgroundColor = backgroundColor;

  Color _backgroundColor;
  set backgroundColor(Color value) {
    if (_backgroundColor == value) return;
    _backgroundColor = value;
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.canvas.drawRect(offset & size, Paint()..color = _backgroundColor);
    super.paint(context, offset);
  }
}
