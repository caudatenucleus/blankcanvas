// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderCustomMultiChildLayout - Multi-delegate layout logic
// =============================================================================

class CustomMultiChildLayoutPrimitive extends MultiChildRenderObjectWidget {
  const CustomMultiChildLayoutPrimitive({
    super.key,
    required this.delegate,
    super.children,
  });
  final MultiChildLayoutDelegate delegate;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderCustomMultiChildLayoutPrimitive(delegate: delegate);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderCustomMultiChildLayoutPrimitive renderObject,
  ) {
    renderObject.delegate = delegate;
  }
}

class RenderCustomMultiChildLayoutPrimitive
    extends RenderCustomMultiChildLayoutBox {
  RenderCustomMultiChildLayoutPrimitive({required super.delegate});
}
