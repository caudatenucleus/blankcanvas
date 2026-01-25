// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// based on the child's size.
class Align extends SingleChildRenderObjectWidget {
  const Align({
    super.key,
    this.alignment = Alignment.center,
    this.widthFactor,
    this.heightFactor,
    super.child,
  });

  final AlignmentGeometry alignment;
  final double? widthFactor;
  final double? heightFactor;

  @override
  RenderPositionedBox createRenderObject(BuildContext context) {
    return RenderPositionedBox(
      alignment: alignment,
      widthFactor: widthFactor,
      heightFactor: heightFactor,
      textDirection: Directionality.maybeOf(context),
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderPositionedBox renderObject,
  ) {
    renderObject
      ..alignment = alignment
      ..widthFactor = widthFactor
      ..heightFactor = heightFactor
      ..textDirection = Directionality.maybeOf(context);
  }
}

class Center extends Align {
  const Center({
    super.key,
    super.widthFactor,
    super.heightFactor,
    super.child,
  }) : super(
         alignment: Alignment.center,
       );
}
