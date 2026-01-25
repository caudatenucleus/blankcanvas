// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderClipRect - Rectangular culling engine
// =============================================================================

class ClipRectPrimitive extends SingleChildRenderObjectWidget {
  const ClipRectPrimitive({
    super.key,
    this.clipBehavior = Clip.hardEdge,
    super.child,
  });
  final Clip clipBehavior;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderClipRectPrimitive(clipBehavior: clipBehavior);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderClipRectPrimitive renderObject,
  ) {
    renderObject.clipBehavior = clipBehavior;
  }
}

class RenderClipRectPrimitive extends RenderProxyBox {
  RenderClipRectPrimitive({Clip clipBehavior = Clip.hardEdge, RenderBox? child})
    : _clipBehavior = clipBehavior,
      super(child);

  Clip _clipBehavior;
  Clip get clipBehavior => _clipBehavior;
  set clipBehavior(Clip value) {
    if (_clipBehavior != value) {
      _clipBehavior = value;
      markNeedsPaint();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;
    if (clipBehavior == Clip.none) {
      context.paintChild(child!, offset);
      return;
    }
    context.pushClipRect(needsCompositing, offset, Offset.zero & size, (
      context,
      offset,
    ) {
      context.paintChild(child!, offset);
    }, clipBehavior: _clipBehavior);
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if ((Offset.zero & size).contains(position)) {
      return super.hitTest(result, position: position);
    }
    return false;
  }
}
