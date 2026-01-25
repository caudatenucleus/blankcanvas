// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderIndexedStack - Lazy multi-child switcher
// =============================================================================

class IndexedStackPrimitive extends MultiChildRenderObjectWidget {
  const IndexedStackPrimitive({
    super.key,
    this.alignment = AlignmentDirectional.topStart,
    this.textDirection,
    this.sizing = StackFit.loose,
    this.index = 0,
    super.children,
  });

  final AlignmentGeometry alignment;
  final TextDirection? textDirection;
  final StackFit sizing;
  final int? index;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderIndexedStackPrimitive(
      alignment: alignment,
      textDirection: textDirection ?? Directionality.maybeOf(context),
      index: index,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderIndexedStackPrimitive renderObject,
  ) {
    renderObject
      ..alignment = alignment
      ..textDirection = textDirection ?? Directionality.maybeOf(context)
      ..index = index;
  }
}

class RenderIndexedStackPrimitive extends RenderIndexedStack {
  RenderIndexedStackPrimitive({
    super.alignment,
    super.textDirection,
    super.index,
  });
}
