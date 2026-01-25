// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderSliverPadding - Sliver inset layout engine
// =============================================================================

class SliverPaddingPrimitive extends SingleChildRenderObjectWidget {
  const SliverPaddingPrimitive({super.key, required this.padding, super.child});
  final EdgeInsets padding;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSliverPaddingPrimitive(padding: padding);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSliverPaddingPrimitive renderObject,
  ) {
    renderObject.padding = padding;
  }
}

class RenderSliverPaddingPrimitive extends RenderSliverEdgeInsetsPadding {
  RenderSliverPaddingPrimitive({required EdgeInsets padding})
    : _padding = padding;

  EdgeInsets _padding;
  EdgeInsets get padding => _padding;
  set padding(EdgeInsets value) {
    if (_padding != value) {
      _padding = value;
      markNeedsLayout();
    }
  }

  @override
  EdgeInsets get resolvedPadding => _padding;
}
