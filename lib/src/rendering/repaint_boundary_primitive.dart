// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderRepaintBoundary - Display-list caching boundary
// =============================================================================

class RepaintBoundaryPrimitive extends SingleChildRenderObjectWidget {
  const RepaintBoundaryPrimitive({super.key, super.child});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderRepaintBoundaryPrimitive();
  }
}

class RenderRepaintBoundaryPrimitive extends RenderProxyBox {
  RenderRepaintBoundaryPrimitive({RenderBox? child}) : super(child);

  @override
  bool get isRepaintBoundary => true;
}
