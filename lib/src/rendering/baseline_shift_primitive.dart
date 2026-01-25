// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderBaselineShift - Typography baseline-offset logic
// =============================================================================

class BaselineShiftPrimitive extends SingleChildRenderObjectWidget {
  const BaselineShiftPrimitive({super.key, required this.shift, super.child});

  final double shift;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderBaselineShiftPrimitive(shift: shift);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderBaselineShiftPrimitive renderObject,
  ) {
    renderObject.shift = shift;
  }
}

class RenderBaselineShiftPrimitive extends RenderProxyBox {
  RenderBaselineShiftPrimitive({required double shift, RenderBox? child})
    : _shift = shift,
      super(child);

  double _shift;
  double get shift => _shift;
  set shift(double value) {
    if (_shift != value) {
      _shift = value;
      markNeedsLayout();
    }
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    final double? childBaseline = super.computeDistanceToActualBaseline(
      baseline,
    );
    if (childBaseline == null) return null;
    return childBaseline + _shift;
  }
}
