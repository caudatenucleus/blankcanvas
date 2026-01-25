// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderExcludeSemantics - AX-subtree pruning engine
// =============================================================================

class ExcludeSemanticsPrimitive extends SingleChildRenderObjectWidget {
  const ExcludeSemanticsPrimitive({
    super.key,
    this.excluding = true,
    super.child,
  });
  final bool excluding;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderExcludeSemanticsPrimitive(excluding: excluding);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderExcludeSemanticsPrimitive renderObject,
  ) {
    renderObject.excluding = excluding;
  }
}

class RenderExcludeSemanticsPrimitive extends RenderExcludeSemantics {
  RenderExcludeSemanticsPrimitive({super.excluding});
}
