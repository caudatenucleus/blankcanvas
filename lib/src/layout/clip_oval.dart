// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';


/// A widget that clips its child using an oval.
class ClipOval extends SingleChildRenderObjectWidget {
  const ClipOval({
    super.key,
    this.clipper,
    this.clipBehavior = Clip.antiAlias,
    super.child,
  });

  final CustomClipper<Rect>? clipper;
  final Clip clipBehavior;

  @override
  RenderClipOval createRenderObject(BuildContext context) {
    return RenderClipOval(clipper: clipper, clipBehavior: clipBehavior);
  }

  @override
  void updateRenderObject(BuildContext context, RenderClipOval renderObject) {
    renderObject
      ..clipper = clipper
      ..clipBehavior = clipBehavior;
  }
}
