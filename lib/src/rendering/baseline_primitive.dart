// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderBaseline - Baseline-alignment layout logic
// =============================================================================

class BaselinePrimitive extends SingleChildRenderObjectWidget {
  const BaselinePrimitive({
    super.key,
    required this.baseline,
    required this.baselineType,
    super.child,
  });
  final double baseline;
  final TextBaseline baselineType;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderBaselinePrimitive(
      baseline: baseline,
      baselineType: baselineType,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderBaselinePrimitive renderObject,
  ) {
    renderObject
      ..baseline = baseline
      ..baselineType = baselineType;
  }
}

class RenderBaselinePrimitive extends RenderShiftedBox {
  RenderBaselinePrimitive({
    required double baseline,
    required TextBaseline baselineType,
    RenderBox? child,
  }) : _baseline = baseline,
       _baselineType = baselineType,
       super(child);

  double _baseline;
  double get baseline => _baseline;
  set baseline(double value) {
    if (_baseline != value) {
      _baseline = value;
      markNeedsLayout();
    }
  }

  TextBaseline _baselineType;
  TextBaseline get baselineType => _baselineType;
  set baselineType(TextBaseline value) {
    if (_baselineType != value) {
      _baselineType = value;
      markNeedsLayout();
    }
  }

  @override
  void performLayout() {
    if (child != null) {
      child!.layout(constraints.loosen(), parentUsesSize: true);
      final double? childBaseline = child!.getDistanceToBaseline(_baselineType);
      final double actualBaseline = childBaseline ?? child!.size.height;
      final double top = _baseline - actualBaseline;
      final BoxParentData childParentData = child!.parentData! as BoxParentData;
      childParentData.offset = Offset(0, top.clamp(0, double.infinity));
      size = constraints.constrain(
        Size(
          child!.size.width,
          top.clamp(0, double.infinity) + child!.size.height,
        ),
      );
    } else {
      size = constraints.smallest;
    }
  }
}
