// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderSliverFillViewport - Viewport-filling sliver engine
// =============================================================================

class SliverFillViewportPrimitive extends SliverMultiBoxAdaptorWidget {
  const SliverFillViewportPrimitive({
    super.key,
    required super.delegate,
    this.viewportFraction = 1.0,
  });
  final double viewportFraction;

  @override
  RenderSliverFillViewportPrimitive createRenderObject(BuildContext context) {
    final element = context as SliverMultiBoxAdaptorElement;
    return RenderSliverFillViewportPrimitive(
      childManager: element,
      viewportFraction: viewportFraction,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSliverFillViewportPrimitive renderObject,
  ) {
    renderObject.viewportFraction = viewportFraction;
  }
}

class RenderSliverFillViewportPrimitive extends RenderSliverFillViewport {
  RenderSliverFillViewportPrimitive({
    required super.childManager,
    super.viewportFraction,
  });
}
