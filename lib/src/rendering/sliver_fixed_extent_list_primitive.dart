// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderSliverFixedExtentList - Optimized sliver engine
// =============================================================================

class SliverFixedExtentListPrimitive extends SliverMultiBoxAdaptorWidget {
  const SliverFixedExtentListPrimitive({
    super.key,
    required super.delegate,
    required this.itemExtent,
  });
  final double itemExtent;

  @override
  RenderSliverMultiBoxAdaptor createRenderObject(BuildContext context) {
    final element = context as SliverMultiBoxAdaptorElement;
    return RenderSliverFixedExtentListPrimitive(
      childManager: element,
      itemExtent: itemExtent,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSliverFixedExtentListPrimitive renderObject,
  ) {
    renderObject.itemExtent = itemExtent;
  }
}

class RenderSliverFixedExtentListPrimitive extends RenderSliverFixedExtentList {
  RenderSliverFixedExtentListPrimitive({
    required super.childManager,
    required super.itemExtent,
  });
}
