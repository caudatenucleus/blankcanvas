// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderLimitedBox - Max-size enforcing layout logic
// =============================================================================

class LimitedBoxPrimitive extends SingleChildRenderObjectWidget {
  const LimitedBoxPrimitive({
    super.key,
    this.maxWidth = double.infinity,
    this.maxHeight = double.infinity,
    super.child,
  });
  final double maxWidth;
  final double maxHeight;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderLimitedBoxPrimitive(maxWidth: maxWidth, maxHeight: maxHeight);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderLimitedBoxPrimitive renderObject,
  ) {
    renderObject
      ..maxWidth = maxWidth
      ..maxHeight = maxHeight;
  }
}

class RenderLimitedBoxPrimitive extends RenderProxyBox {
  RenderLimitedBoxPrimitive({
    double maxWidth = double.infinity,
    double maxHeight = double.infinity,
    RenderBox? child,
  }) : _maxWidth = maxWidth,
       _maxHeight = maxHeight,
       super(child);

  double _maxWidth;
  double get maxWidth => _maxWidth;
  set maxWidth(double value) {
    if (_maxWidth != value) {
      _maxWidth = value;
      markNeedsLayout();
    }
  }

  double _maxHeight;
  double get maxHeight => _maxHeight;
  set maxHeight(double value) {
    if (_maxHeight != value) {
      _maxHeight = value;
      markNeedsLayout();
    }
  }

  @override
  void performLayout() {
    if (child != null) {
      BoxConstraints effectiveConstraints = constraints;
      if (!constraints.hasBoundedWidth) {
        effectiveConstraints = effectiveConstraints.copyWith(
          maxWidth: _maxWidth,
        );
      }
      if (!constraints.hasBoundedHeight) {
        effectiveConstraints = effectiveConstraints.copyWith(
          maxHeight: _maxHeight,
        );
      }
      child!.layout(effectiveConstraints, parentUsesSize: true);
      size = child!.size;
    } else {
      size = constraints.smallest;
    }
  }
}
