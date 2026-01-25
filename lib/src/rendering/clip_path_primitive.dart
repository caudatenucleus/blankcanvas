// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderClipPath - Path-based stencil culling engine
// =============================================================================

typedef PathClipperPrimitive = Path Function(Size size);

class ClipPathPrimitive extends SingleChildRenderObjectWidget {
  const ClipPathPrimitive({
    super.key,
    required this.clipper,
    this.clipBehavior = Clip.antiAlias,
    super.child,
  });
  final PathClipperPrimitive clipper;
  final Clip clipBehavior;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderClipPathPrimitive(
      clipper: clipper,
      clipBehavior: clipBehavior,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderClipPathPrimitive renderObject,
  ) {
    renderObject
      ..clipper = clipper
      ..clipBehavior = clipBehavior;
  }
}

class RenderClipPathPrimitive extends RenderProxyBox {
  RenderClipPathPrimitive({
    required PathClipperPrimitive clipper,
    Clip clipBehavior = Clip.antiAlias,
    RenderBox? child,
  }) : _clipper = clipper,
       _clipBehavior = clipBehavior,
       super(child);

  PathClipperPrimitive _clipper;
  set clipper(PathClipperPrimitive value) {
    _clipper = value;
    markNeedsPaint();
  }

  Clip _clipBehavior;
  set clipBehavior(Clip value) {
    if (_clipBehavior != value) {
      _clipBehavior = value;
      markNeedsPaint();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;
    final Path path = _clipper(size);
    context.pushClipPath(needsCompositing, offset, Offset.zero & size, path, (
      context,
      offset,
    ) {
      context.paintChild(child!, offset);
    }, clipBehavior: _clipBehavior);
  }
}
