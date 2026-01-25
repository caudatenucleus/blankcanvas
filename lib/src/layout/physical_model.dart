// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';


/// A widget that draws a physical model.
class PhysicalModel extends SingleChildRenderObjectWidget {
  const PhysicalModel({
    super.key,
    this.shape = BoxShape.rectangle,
    this.clipBehavior = Clip.none,
    this.borderRadius,
    this.elevation = 0.0,
    required this.color,
    this.shadowColor = const Color(0xFF000000),
    super.child,
  });

  final BoxShape shape;
  final Clip clipBehavior;
  final BorderRadius? borderRadius;
  final double elevation;
  final Color color;
  final Color shadowColor;

  @override
  RenderPhysicalModel createRenderObject(BuildContext context) {
    return RenderPhysicalModel(
      shape: shape,
      clipBehavior: clipBehavior,
      borderRadius: borderRadius,
      elevation: elevation,
      color: color,
      shadowColor: shadowColor,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderPhysicalModel renderObject,
  ) {
    renderObject
      ..shape = shape
      ..clipBehavior = clipBehavior
      ..borderRadius = borderRadius
      ..elevation = elevation
      ..color = color
      ..shadowColor = shadowColor;
  }
}

/// A widget that provides a canvas for immediate mode drawing.