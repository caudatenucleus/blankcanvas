// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderSliverFillRemaining - Viewport-exhaustion engine
// =============================================================================

class SliverFillRemainingPrimitive extends SingleChildRenderObjectWidget {
  const SliverFillRemainingPrimitive({super.key, super.child});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSliverFillRemainingPrimitive();
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSliverFillRemainingPrimitive renderObject,
  ) {
    // No properties to update
  }
}

class RenderSliverFillRemainingPrimitive extends RenderSliverFillRemaining {
  RenderSliverFillRemainingPrimitive();
}
