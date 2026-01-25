// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderSliverGrid - 2D scrollable grid engine
// =============================================================================

class SliverGridPrimitive extends SliverMultiBoxAdaptorWidget {
  const SliverGridPrimitive({
    super.key,
    required super.delegate,
    required this.gridDelegate,
  });
  final SliverGridDelegate gridDelegate;

  @override
  RenderSliverGridPrimitive createRenderObject(BuildContext context) {
    final element = context as SliverMultiBoxAdaptorElement;
    return RenderSliverGridPrimitive(
      childManager: element,
      gridDelegate: gridDelegate,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSliverGridPrimitive renderObject,
  ) {
    renderObject.gridDelegate = gridDelegate;
  }
}

class RenderSliverGridPrimitive extends RenderSliverGrid {
  RenderSliverGridPrimitive({
    required super.childManager,
    required super.gridDelegate,
  });
}
