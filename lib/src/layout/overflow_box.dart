import 'package:flutter/widgets.dart';
// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';


/// from its parent, possibly allowing the child to overflow the parent.
class OverflowBox extends SingleChildRenderObjectWidget {
  const OverflowBox({
    super.key,
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    this.alignment = Alignment.center,
    super.child,
  });

  final double? minWidth;
  final double? maxWidth;
  final double? minHeight;
  final double? maxHeight;
  final AlignmentGeometry alignment;

  @override
  RenderConstrainedOverflowBox createRenderObject(BuildContext context) {
    return RenderConstrainedOverflowBox(
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,
      alignment: alignment,
      textDirection: Directionality.maybeOf(context),
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderConstrainedOverflowBox renderObject,
  ) {
    renderObject
      ..minWidth = minWidth
      ..maxWidth = maxWidth
      ..minHeight = minHeight
      ..maxHeight = maxHeight
      ..alignment = alignment
      ..textDirection = Directionality.maybeOf(context);
  }
}

/// A widget that is a specific size but passes its original constraints