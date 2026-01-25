// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderIntrinsicHeight - Content-sized height calculation
// =============================================================================

class IntrinsicHeightPrimitive extends SingleChildRenderObjectWidget {
  const IntrinsicHeightPrimitive({super.key, super.child});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderIntrinsicHeightPrimitive();
  }
}

class RenderIntrinsicHeightPrimitive extends RenderProxyBox {
  RenderIntrinsicHeightPrimitive({RenderBox? child}) : super(child);

  @override
  void performLayout() {
    if (child != null) {
      BoxConstraints childConstraints = constraints;
      if (!constraints.hasTightHeight) {
        final double height = child!.getMaxIntrinsicHeight(
          constraints.maxWidth,
        );
        childConstraints = constraints.tighten(height: height);
      }
      child!.layout(childConstraints, parentUsesSize: true);
      size = child!.size;
    } else {
      size = constraints.smallest;
    }
  }
}
