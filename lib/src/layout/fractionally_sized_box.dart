import 'package:flutter/widgets.dart';
// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';


/// A widget that sizes its child to a fraction of the total available space.
class FractionallySizedBox extends SingleChildRenderObjectWidget {
  const FractionallySizedBox({
    super.key,
    this.alignment = Alignment.center,
    this.widthFactor,
    this.heightFactor,
    super.child,
  });

  final double? widthFactor;
  final double? heightFactor;
  final AlignmentGeometry alignment;

  @override
  RenderFractionallySizedOverflowBox createRenderObject(BuildContext context) {
    return RenderFractionallySizedOverflowBox(
      widthFactor: widthFactor,
      heightFactor: heightFactor,
      alignment: alignment,
      textDirection: Directionality.maybeOf(context),
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderFractionallySizedOverflowBox renderObject,
  ) {
    renderObject
      ..widthFactor = widthFactor
      ..heightFactor = heightFactor
      ..alignment = alignment
      ..textDirection = Directionality.maybeOf(context);
  }
}
