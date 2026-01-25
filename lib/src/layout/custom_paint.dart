// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';


/// A widget that provides a canvas on which to draw during the paint phase.
class CustomPaint extends SingleChildRenderObjectWidget {
  const CustomPaint({
    super.key,
    this.painter,
    this.foregroundPainter,
    this.size = Size.zero,
    this.isComplex = false,
    this.willChange = false,
    super.child,
  });

  final CustomPainter? painter;
  final CustomPainter? foregroundPainter;
  final Size size;
  final bool isComplex;
  final bool willChange;

  @override
  RenderCustomPaint createRenderObject(BuildContext context) {
    return RenderCustomPaint(
      painter: painter,
      foregroundPainter: foregroundPainter,
      preferredSize: size,
      isComplex: isComplex,
      willChange: willChange,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderCustomPaint renderObject,
  ) {
    renderObject
      ..painter = painter
      ..foregroundPainter = foregroundPainter
      ..preferredSize = size
      ..isComplex = isComplex
      ..willChange = willChange;
  }

  @override
  void didUnmountRenderObject(RenderCustomPaint renderObject) {
    renderObject
      ..painter = null
      ..foregroundPainter = null;
  }
}
