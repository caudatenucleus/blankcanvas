// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderSliverOffstage - Layout-only sliver state
// =============================================================================

class SliverOffstagePrimitive extends SingleChildRenderObjectWidget {
  const SliverOffstagePrimitive({super.key, this.offstage = true, super.child});
  final bool offstage;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSliverOffstagePrimitive(offstage: offstage);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSliverOffstagePrimitive renderObject,
  ) {
    renderObject.offstage = offstage;
  }
}

class RenderSliverOffstagePrimitive extends RenderSliverOffstage {
  RenderSliverOffstagePrimitive({super.offstage});
}
