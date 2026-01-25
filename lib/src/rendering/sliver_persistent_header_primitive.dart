// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderSliverPersistentHeader - Sticky/Floating sliver engine
// =============================================================================

class SliverPersistentHeaderPrimitive extends SingleChildRenderObjectWidget {
  const SliverPersistentHeaderPrimitive({
    super.key,
    required this.minExtent,
    required this.maxExtent,
    super.child,
  });
  final double minExtent;
  final double maxExtent;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSliverPinnedPersistentHeaderPrimitive(
      minExtent: minExtent,
      maxExtent: maxExtent,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSliverPinnedPersistentHeaderPrimitive renderObject,
  ) {
    renderObject
      ..minExtent = minExtent
      ..maxExtent = maxExtent;
  }
}

class RenderSliverPinnedPersistentHeaderPrimitive
    extends RenderSliverPinnedPersistentHeader {
  RenderSliverPinnedPersistentHeaderPrimitive({
    double minExtent = 0.0,
    double maxExtent = 0.0,
  }) : _minExtent = minExtent,
       _maxExtent = maxExtent;

  double _minExtent;
  @override
  double get minExtent => _minExtent;
  set minExtent(double value) {
    if (_minExtent != value) {
      _minExtent = value;
      markNeedsLayout();
    }
  }

  double _maxExtent;
  @override
  double get maxExtent => _maxExtent;
  set maxExtent(double value) {
    if (_maxExtent != value) {
      _maxExtent = value;
      markNeedsLayout();
    }
  }
}
