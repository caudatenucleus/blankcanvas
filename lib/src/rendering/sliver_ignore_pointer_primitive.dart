// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderSliverIgnorePointer - Low-level interaction culling
// =============================================================================

class SliverIgnorePointerPrimitive extends SingleChildRenderObjectWidget {
  const SliverIgnorePointerPrimitive({
    super.key,
    this.ignoring = true,
    this.ignoringSemantics,
    super.child,
  });
  final bool ignoring;
  final bool? ignoringSemantics;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSliverIgnorePointerPrimitive(
      ignoring: ignoring,
      ignoringSemantics: ignoringSemantics,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSliverIgnorePointerPrimitive renderObject,
  ) {
    renderObject
      ..ignoring = ignoring
      ..ignoringSemantics = ignoringSemantics;
  }
}

class RenderSliverIgnorePointerPrimitive extends RenderSliverIgnorePointer {
  RenderSliverIgnorePointerPrimitive({super.ignoring, super.ignoringSemantics});
}
