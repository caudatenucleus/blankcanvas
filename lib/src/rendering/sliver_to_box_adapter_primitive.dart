// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderSliverToBoxAdapter - Box-to-Sliver bridge engine
// =============================================================================

class SliverToBoxAdapterPrimitive extends SingleChildRenderObjectWidget {
  const SliverToBoxAdapterPrimitive({super.key, super.child});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSliverToBoxAdapterPrimitive();
  }
}

class RenderSliverToBoxAdapterPrimitive extends RenderSliverSingleBoxAdapter {
  @override
  void performLayout() {
    if (child == null) {
      geometry = SliverGeometry.zero;
      return;
    }

    final SliverConstraints constraints = this.constraints;
    child!.layout(constraints.asBoxConstraints(), parentUsesSize: true);

    final double childExtent;
    switch (constraints.axis) {
      case Axis.horizontal:
        childExtent = child!.size.width;
        break;
      case Axis.vertical:
        childExtent = child!.size.height;
        break;
    }

    final double paintedChildExtent = calculatePaintOffset(
      constraints,
      from: 0.0,
      to: childExtent,
    );
    final double cacheExtent = calculateCacheOffset(
      constraints,
      from: 0.0,
      to: childExtent,
    );

    geometry = SliverGeometry(
      scrollExtent: childExtent,
      paintExtent: paintedChildExtent,
      cacheExtent: cacheExtent,
      maxPaintExtent: childExtent,
      hitTestExtent: paintedChildExtent,
      hasVisualOverflow:
          childExtent > constraints.remainingPaintExtent ||
          constraints.scrollOffset > 0.0,
    );

    setChildParentData(child!, constraints, geometry!);
  }
}
