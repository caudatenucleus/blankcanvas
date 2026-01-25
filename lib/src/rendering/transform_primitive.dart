// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

// =============================================================================
// RenderTransform - Matrix4x4 coordinate transform engine
// =============================================================================

class TransformPrimitive extends SingleChildRenderObjectWidget {
  const TransformPrimitive({
    super.key,
    required this.transform,
    this.alignment = Alignment.center,
    super.child,
  });
  final Matrix4 transform;
  final Alignment alignment;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderTransformPrimitive(transform: transform, alignment: alignment);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderTransformPrimitive renderObject,
  ) {
    renderObject
      ..transform = transform
      ..alignment = alignment;
  }
}

class RenderTransformPrimitive extends RenderProxyBox {
  RenderTransformPrimitive({
    Matrix4? transform,
    Alignment alignment = Alignment.center,
    RenderBox? child,
  }) : _transform = transform ?? Matrix4.identity(),
       _alignment = alignment,
       super(child);

  Matrix4 _transform;
  Matrix4 get transform => _transform;
  set transform(Matrix4 value) {
    if (_transform != value) {
      _transform = value;
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
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;
    final Offset childOffset = _alignment.alongSize(size);
    final Matrix4 effectiveTransform =
        Matrix4.translationValues(childOffset.dx, childOffset.dy, 0.0)
          ..multiply(_transform)
          ..translate(Vector3(-childOffset.dx, -childOffset.dy, 0.0));
    context.pushTransform(needsCompositing, offset, effectiveTransform, (
      context,
      offset,
    ) {
      context.paintChild(child!, offset);
    });
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return result.addWithPaintTransform(
      transform: _transform,
      position: position,
      hitTest: (BoxHitTestResult result, Offset position) {
        return child?.hitTest(result, position: position) ?? false;
      },
    );
  }
}
