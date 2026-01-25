// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';


/// A widget that clips its child using a rectangle.
class ClipRect extends SingleChildRenderObjectWidget {
  const ClipRect({
    super.key,
    this.clipper,
    this.clipBehavior = Clip.hardEdge,
    super.child,
  });

  final CustomClipper<Rect>? clipper;
  final Clip clipBehavior;

  @override
  RenderClipRect createRenderObject(BuildContext context) {
    return RenderClipRect(clipper: clipper, clipBehavior: clipBehavior);
  }

  @override
  void updateRenderObject(BuildContext context, RenderClipRect renderObject) {
    renderObject
      ..clipper = clipper
      ..clipBehavior = clipBehavior;
  }
}
