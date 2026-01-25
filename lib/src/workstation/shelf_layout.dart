// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// Shelf container primitive (horizontal strict layout) using lowest-level RenderObject APIs.
class ShelfLayout extends MultiChildRenderObjectWidget {
  const ShelfLayout({super.key, required super.children, this.height = 40.0});

  final double height;

  @override
  RenderShelfLayout createRenderObject(BuildContext context) {
    return RenderShelfLayout(height: height);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderShelfLayout renderObject,
  ) {
    renderObject.height = height;
  }
}

class RenderShelfLayout extends RenderBox
    with
        ContainerRenderObjectMixin<
          RenderBox,
          ContainerBoxParentData<RenderBox>
        >,
        RenderBoxContainerDefaultsMixin<
          RenderBox,
          ContainerBoxParentData<RenderBox>
        > {
  RenderShelfLayout({required double height}) : _height = height;

  double _height;
  set height(double value) {
    if (_height == value) return;
    _height = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    size = constraints.constrain(Size(double.infinity, _height));
    double x = 0;
    RenderBox? child = firstChild;
    while (child != null) {
      child.layout(
        BoxConstraints.tightFor(height: _height),
        parentUsesSize: true,
      );
      final pd = child.parentData as ContainerBoxParentData<RenderBox>;
      pd.offset = Offset(x, 0);
      x += child.size.width;
      child = childAfter(child);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
