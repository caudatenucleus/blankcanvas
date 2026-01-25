import 'package:flutter/widgets.dart';
// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';


/// through to its child, which may then overflow.
class SizedOverflowBox extends SingleChildRenderObjectWidget {
  const SizedOverflowBox({
    super.key,
    required this.size,
    this.alignment = Alignment.center,
    super.child,
  });

  final Size size;
  final AlignmentGeometry alignment;

  @override
  RenderSizedOverflowBox createRenderObject(BuildContext context) {
    return RenderSizedOverflowBox(
      requestedSize: size,
      alignment: alignment,
      textDirection: Directionality.maybeOf(context),
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSizedOverflowBox renderObject,
  ) {
    renderObject
      ..requestedSize = size
      ..alignment = alignment
      ..textDirection = Directionality.maybeOf(context);
  }
}
