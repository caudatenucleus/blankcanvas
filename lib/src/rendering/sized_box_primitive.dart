// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderSizedBox - Exact sizing constraint engine
// =============================================================================

class SizedBoxPrimitive extends SingleChildRenderObjectWidget {
  const SizedBoxPrimitive({super.key, this.width, this.height, super.child});
  final double? width;
  final double? height;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSizedBoxPrimitive(width: width, height: height);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSizedBoxPrimitive renderObject,
  ) {
    renderObject
      ..overrideWidth = width
      ..overrideHeight = height;
  }
}

class RenderSizedBoxPrimitive extends RenderProxyBox {
  RenderSizedBoxPrimitive({double? width, double? height, RenderBox? child})
    : _width = width,
      _height = height,
      super(child);

  double? _width;
  set overrideWidth(double? value) {
    if (_width != value) {
      _width = value;
      markNeedsLayout();
    }
  }

  double? _height;
  set overrideHeight(double? value) {
    if (_height != value) {
      _height = value;
      markNeedsLayout();
    }
  }

  @override
  void performLayout() {
    final BoxConstraints effectiveConstraints = BoxConstraints.tightFor(
      width: _width,
      height: _height,
    ).enforce(constraints);

    if (child != null) {
      child!.layout(effectiveConstraints, parentUsesSize: true);
      size = child!.size;
    } else {
      size = effectiveConstraints.constrain(Size.zero);
    }
  }
}
