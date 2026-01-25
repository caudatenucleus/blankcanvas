// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderAspectRatio - Ratio-enforcing layout logic
// =============================================================================

class AspectRatioPrimitive extends SingleChildRenderObjectWidget {
  const AspectRatioPrimitive({
    super.key,
    required this.aspectRatio,
    super.child,
  });
  final double aspectRatio;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderAspectRatioPrimitive(aspectRatio: aspectRatio);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderAspectRatioPrimitive renderObject,
  ) {
    renderObject.aspectRatio = aspectRatio;
  }
}

class RenderAspectRatioPrimitive extends RenderProxyBox {
  RenderAspectRatioPrimitive({double aspectRatio = 1.0, RenderBox? child})
    : _aspectRatio = aspectRatio,
      super(child);

  double _aspectRatio;
  double get aspectRatio => _aspectRatio;
  set aspectRatio(double value) {
    if (_aspectRatio != value) {
      _aspectRatio = value;
      markNeedsLayout();
    }
  }

  @override
  void performLayout() {
    if (constraints.isTight) {
      size = constraints.smallest;
      if (child != null) {
        child!.layout(BoxConstraints.tight(size));
      }
      return;
    }

    double width = constraints.maxWidth;
    double height = width / _aspectRatio;

    if (height > constraints.maxHeight) {
      height = constraints.maxHeight;
      width = height * _aspectRatio;
    }

    size = constraints.constrain(Size(width, height));
    if (child != null) {
      child!.layout(BoxConstraints.tight(size));
    }
  }
}
