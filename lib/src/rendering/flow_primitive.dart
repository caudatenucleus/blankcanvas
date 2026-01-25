// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderFlow - Matrix-optimized animation layout engine
// =============================================================================

class FlowPrimitive extends MultiChildRenderObjectWidget {
  const FlowPrimitive({
    super.key,
    required this.delegate,
    super.children,
    this.clipBehavior = Clip.hardEdge,
  });
  final FlowDelegate delegate;
  final Clip clipBehavior;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderFlowPrimitive(delegate: delegate, clipBehavior: clipBehavior);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderFlowPrimitive renderObject,
  ) {
    renderObject
      ..delegate = delegate
      ..clipBehavior = clipBehavior;
  }
}

class RenderFlowPrimitive extends RenderFlow {
  RenderFlowPrimitive({required super.delegate, super.clipBehavior});
}
