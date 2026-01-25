// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderSliverFadeTransition - Opacity-aware sliver engine
// =============================================================================

class SliverFadeTransitionPrimitive extends SingleChildRenderObjectWidget {
  const SliverFadeTransitionPrimitive({
    super.key,
    required this.opacity,
    this.alwaysIncludeSemantics = false,
    super.child,
  });

  final Animation<double> opacity;
  final bool alwaysIncludeSemantics;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSliverFadeTransitionPrimitive(
      opacity: opacity,
      alwaysIncludeSemantics: alwaysIncludeSemantics,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSliverFadeTransitionPrimitive renderObject,
  ) {
    renderObject
      ..animatedOpacity = opacity
      ..alwaysIncludeSemantics = alwaysIncludeSemantics;
  }
}

class RenderSliverFadeTransitionPrimitive extends RenderSliverAnimatedOpacity {
  RenderSliverFadeTransitionPrimitive({
    required super.opacity,
    super.alwaysIncludeSemantics,
  });

  set animatedOpacity(Animation<double> value) {
    opacity = value;
  }
}
