// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';


/// A widget that clips its child using a path.
class ClipPath extends SingleChildRenderObjectWidget {
  const ClipPath({
    super.key,
    this.clipper,
    this.clipBehavior = Clip.antiAlias,
    super.child,
  });

  final CustomClipper<Path>? clipper;
  final Clip clipBehavior;

  @override
  RenderClipPath createRenderObject(BuildContext context) {
    return RenderClipPath(clipper: clipper, clipBehavior: clipBehavior);
  }

  @override
  void updateRenderObject(BuildContext context, RenderClipPath renderObject) {
    renderObject
      ..clipper = clipper
      ..clipBehavior = clipBehavior;
  }
}
