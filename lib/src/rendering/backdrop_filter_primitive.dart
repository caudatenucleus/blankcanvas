// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui' as ui;

// =============================================================================
// RenderBackdropFilter - Recursive background blur engine
// =============================================================================

class BackdropFilterPrimitive extends SingleChildRenderObjectWidget {
  const BackdropFilterPrimitive({
    super.key,
    required this.filter,
    this.blendMode = BlendMode.srcOver,
    super.child,
  });
  final ui.ImageFilter filter;
  final BlendMode blendMode;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderBackdropFilterPrimitive(filter: filter, blendMode: blendMode);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderBackdropFilterPrimitive renderObject,
  ) {
    renderObject
      ..filter = filter
      ..blendMode = blendMode;
  }
}

class RenderBackdropFilterPrimitive extends RenderProxyBox {
  RenderBackdropFilterPrimitive({
    required ui.ImageFilter filter,
    BlendMode blendMode = BlendMode.srcOver,
    RenderBox? child,
  }) : _filter = filter,
       _blendMode = blendMode,
       super(child);

  ui.ImageFilter _filter;
  set filter(ui.ImageFilter value) {
    _filter = value;
    markNeedsPaint();
  }

  BlendMode _blendMode;
  set blendMode(BlendMode value) {
    if (_blendMode != value) {
      _blendMode = value;
      markNeedsPaint();
    }
  }

  @override
  bool get alwaysNeedsCompositing => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    context.pushLayer(
      BackdropFilterLayer(filter: _filter, blendMode: _blendMode),
      (context, offset) {
        if (child != null) context.paintChild(child!, offset);
      },
      offset,
    );
  }
}
