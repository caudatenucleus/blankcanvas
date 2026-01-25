// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// Content-aware toolbar logic using lowest-level RenderObject APIs.
class ContextualToolBar extends MultiChildRenderObjectWidget {
  const ContextualToolBar({
    super.key,
    required super.children,
    this.height = 36.0,
  });

  final double height;

  @override
  RenderContextualToolBar createRenderObject(BuildContext context) {
    return RenderContextualToolBar(height: height);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderContextualToolBar renderObject,
  ) {
    renderObject.height = height;
  }
}

class RenderContextualToolBar extends RenderBox
    with
        ContainerRenderObjectMixin<
          RenderBox,
          ContainerBoxParentData<RenderBox>
        >,
        RenderBoxContainerDefaultsMixin<
          RenderBox,
          ContainerBoxParentData<RenderBox>
        > {
  RenderContextualToolBar({required double height}) : _height = height;

  double _height;
  set height(double value) {
    if (_height == value) return;
    _height = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    size = constraints.constrain(Size(double.infinity, _height));
    // Implementation for tool horizontal layout
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}
