// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderClipRRect - Rounded-rectangular culling engine
// =============================================================================

class ClipRRectPrimitive extends SingleChildRenderObjectWidget {
  const ClipRRectPrimitive({
    super.key,
    required this.borderRadius,
    this.clipBehavior = Clip.antiAlias,
    super.child,
  });
  final BorderRadius borderRadius;
  final Clip clipBehavior;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderClipRRectPrimitive(
      borderRadius: borderRadius,
      clipBehavior: clipBehavior,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderClipRRectPrimitive renderObject,
  ) {
    renderObject
      ..borderRadius = borderRadius
      ..clipBehavior = clipBehavior;
  }
}

class RenderClipRRectPrimitive extends RenderProxyBox {
  RenderClipRRectPrimitive({
    BorderRadius borderRadius = BorderRadius.zero,
    Clip clipBehavior = Clip.antiAlias,
    RenderBox? child,
  }) : _borderRadius = borderRadius,
       _clipBehavior = clipBehavior,
       super(child);

  BorderRadius _borderRadius;
  BorderRadius get borderRadius => _borderRadius;
  set borderRadius(BorderRadius value) {
    if (_borderRadius != value) {
      _borderRadius = value;
      markNeedsPaint();
    }
  }

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
    final RRect rrect = _borderRadius.toRRect(Offset.zero & size);
    context.pushClipRRect(needsCompositing, offset, Offset.zero & size, rrect, (
      context,
      offset,
    ) {
      context.paintChild(child!, offset);
    }, clipBehavior: _clipBehavior);
  }
}
