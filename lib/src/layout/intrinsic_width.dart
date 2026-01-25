// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';


/// A widget that forces its child's width to be the child's intrinsic width.
class IntrinsicWidth extends SingleChildRenderObjectWidget {
  const IntrinsicWidth({
    super.key,
    this.stepWidth,
    this.stepHeight,
    super.child,
  });

  final double? stepWidth;
  final double? stepHeight;

  @override
  RenderIntrinsicWidth createRenderObject(BuildContext context) {
    return RenderIntrinsicWidth(stepWidth: stepWidth, stepHeight: stepHeight);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderIntrinsicWidth renderObject,
  ) {
    renderObject
      ..stepWidth = stepWidth
      ..stepHeight = stepHeight;
  }
}
