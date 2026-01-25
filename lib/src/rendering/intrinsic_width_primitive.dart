// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderIntrinsicWidth - Content-sized width calculation
// =============================================================================

class IntrinsicWidthPrimitive extends SingleChildRenderObjectWidget {
  const IntrinsicWidthPrimitive({
    super.key,
    this.stepWidth,
    this.stepHeight,
    super.child,
  });
  final double? stepWidth;
  final double? stepHeight;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderIntrinsicWidthPrimitive(
      stepWidth: stepWidth,
      stepHeight: stepHeight,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderIntrinsicWidthPrimitive renderObject,
  ) {
    renderObject
      ..stepWidth = stepWidth
      ..stepHeight = stepHeight;
  }
}

class RenderIntrinsicWidthPrimitive extends RenderProxyBox {
  RenderIntrinsicWidthPrimitive({
    double? stepWidth,
    double? stepHeight,
    RenderBox? child,
  }) : _stepWidth = stepWidth,
       _stepHeight = stepHeight,
       super(child);

  double? _stepWidth;
  set stepWidth(double? value) {
    if (_stepWidth != value) {
      _stepWidth = value;
      markNeedsLayout();
    }
  }

  double? _stepHeight;
  set stepHeight(double? value) {
    if (_stepHeight != value) {
      _stepHeight = value;
      markNeedsLayout();
    }
  }

  static double _applyStep(double input, double? step) {
    if (step == null || step == 0) return input;
    return (input / step).ceil() * step;
  }

  @override
  void performLayout() {
    if (child != null) {
      BoxConstraints childConstraints = constraints;
      if (!constraints.hasTightWidth) {
        final double width = child!.getMaxIntrinsicWidth(constraints.maxHeight);
        childConstraints = constraints.tighten(
          width: _applyStep(width, _stepWidth),
        );
      }
      child!.layout(childConstraints, parentUsesSize: true);
      size = child!.size;
    } else {
      size = constraints.smallest;
    }
  }
}
