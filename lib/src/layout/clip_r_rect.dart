import 'package:flutter/widgets.dart';
// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';


/// A widget that clips its child using a rounded rectangle.
class ClipRRect extends SingleChildRenderObjectWidget {
  const ClipRRect({
    super.key,
    this.borderRadius = BorderRadius.zero,
    this.clipper,
    this.clipBehavior = Clip.antiAlias,
    super.child,
  });

  final BorderRadiusGeometry borderRadius;
  final CustomClipper<RRect>? clipper;
  final Clip clipBehavior;

  @override
  RenderClipRRect createRenderObject(BuildContext context) {
    return RenderClipRRect(
      borderRadius: borderRadius,
      clipper: clipper,
      clipBehavior: clipBehavior,
      textDirection: Directionality.maybeOf(context),
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderClipRRect renderObject) {
    renderObject
      ..borderRadius = borderRadius
      ..clipper = clipper
      ..clipBehavior = clipBehavior
      ..textDirection = Directionality.maybeOf(context);
  }
}
