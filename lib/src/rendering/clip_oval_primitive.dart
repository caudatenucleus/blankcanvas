// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderClipOval - Circular culling engine
// =============================================================================

class ClipOvalPrimitive extends SingleChildRenderObjectWidget {
  const ClipOvalPrimitive({
    super.key,
    this.clipBehavior = Clip.antiAlias,
    super.child,
  });
  final Clip clipBehavior;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderClipOvalPrimitive(clipBehavior: clipBehavior);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderClipOvalPrimitive renderObject,
  ) {
    renderObject.clipBehavior = clipBehavior;
  }
}

class RenderClipOvalPrimitive extends RenderProxyBox {
  RenderClipOvalPrimitive({
    Clip clipBehavior = Clip.antiAlias,
    RenderBox? child,
  }) : _clipBehavior = clipBehavior,
       super(child);

  Clip _clipBehavior;
  Clip get clipBehavior => _clipBehavior;
  set clipBehavior(Clip value) {
    if (_clipBehavior != value) {
      _clipBehavior = value;
      markNeedsPaint();
    }
  }

  Rect _getOvalBounds() => Offset.zero & size;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;
    context.pushClipPath(
      needsCompositing,
      offset,
      _getOvalBounds(),
      Path()..addOval(_getOvalBounds()),
      (context, offset) {
        context.paintChild(child!, offset);
      },
      clipBehavior: _clipBehavior,
    );
  }
}
