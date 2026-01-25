// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

// =============================================================================
// RenderFittedBox - Scale-to-fit algorithmic engine
// =============================================================================

class FittedBoxPrimitive extends SingleChildRenderObjectWidget {
  const FittedBoxPrimitive({
    super.key,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    super.child,
  });
  final BoxFit fit;
  final Alignment alignment;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderFittedBoxPrimitive(fit: fit, alignment: alignment);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderFittedBoxPrimitive renderObject,
  ) {
    renderObject
      ..fit = fit
      ..alignment = alignment;
  }
}

class RenderFittedBoxPrimitive extends RenderProxyBox {
  RenderFittedBoxPrimitive({
    BoxFit fit = BoxFit.contain,
    Alignment alignment = Alignment.center,
    RenderBox? child,
  }) : _fit = fit,
       _alignment = alignment,
       super(child);

  BoxFit _fit;
  BoxFit get fit => _fit;
  set fit(BoxFit value) {
    if (_fit != value) {
      _fit = value;
      markNeedsPaint();
    }
  }

  Alignment _alignment;
  Alignment get alignment => _alignment;
  set alignment(Alignment value) {
    if (_alignment != value) {
      _alignment = value;
      markNeedsPaint();
    }
  }

  @override
  void performLayout() {
    if (child != null) {
      child!.layout(const BoxConstraints(), parentUsesSize: true);
      size = constraints.constrainSizeAndAttemptToPreserveAspectRatio(
        child!.size,
      );
    } else {
      size = constraints.smallest;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;

    final Size childSize = child!.size;
    final FittedSizes sizes = applyBoxFit(_fit, childSize, size);
    final double scaleX = sizes.destination.width / sizes.source.width;
    final double scaleY = sizes.destination.height / sizes.source.height;

    final Offset sourceOffset = _alignment.alongSize(sizes.source);
    final Offset destinationOffset = _alignment.alongSize(sizes.destination);

    final Matrix4 transform =
        Matrix4.translationValues(
            offset.dx + destinationOffset.dx,
            offset.dy + destinationOffset.dy,
            0.0,
          )
          ..scale(Vector3(scaleX, scaleY, 1.0))
          ..translate(Vector3(-sourceOffset.dx, -sourceOffset.dy, 0.0));

    context.pushTransform(needsCompositing, Offset.zero, transform, (
      context,
      offset,
    ) {
      context.paintChild(child!, offset);
    });
  }
}
