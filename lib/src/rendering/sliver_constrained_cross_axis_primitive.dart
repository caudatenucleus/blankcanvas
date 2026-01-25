// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderSliverConstrainedCrossAxis - Secondary-axis constraint
// =============================================================================

class SliverConstrainedCrossAxisPrimitive
    extends SingleChildRenderObjectWidget {
  const SliverConstrainedCrossAxisPrimitive({
    super.key,
    required this.maxExtent,
    super.child,
  });

  final double maxExtent;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSliverConstrainedCrossAxisPrimitive(maxExtent: maxExtent);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSliverConstrainedCrossAxisPrimitive renderObject,
  ) {
    renderObject.maxExtent = maxExtent;
  }
}

class RenderSliverConstrainedCrossAxisPrimitive
    extends RenderSliverConstrainedCrossAxis {
  RenderSliverConstrainedCrossAxisPrimitive({required super.maxExtent});
}
