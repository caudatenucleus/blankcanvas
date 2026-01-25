// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderSliverOpacity - Composite-layer sliver alpha
// =============================================================================

class SliverOpacityPrimitive extends SingleChildRenderObjectWidget {
  const SliverOpacityPrimitive({
    super.key,
    required this.opacity,
    this.alwaysIncludeSemantics = false,
    super.child,
  });

  final double opacity;
  final bool alwaysIncludeSemantics;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSliverOpacityPrimitive(
      opacity: opacity,
      alwaysIncludeSemantics: alwaysIncludeSemantics,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSliverOpacityPrimitive renderObject,
  ) {
    renderObject
      ..opacity = opacity
      ..alwaysIncludeSemantics = alwaysIncludeSemantics;
  }
}

class RenderSliverOpacityPrimitive extends RenderSliverOpacity {
  RenderSliverOpacityPrimitive({super.opacity, super.alwaysIncludeSemantics});
}
