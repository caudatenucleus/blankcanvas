// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// Search overlay primitive (Command Palette style) using lowest-level RenderObject APIs.
class CommandSearch extends SingleChildRenderObjectWidget {
  const CommandSearch({
    super.key,
    required super.child, // The input field
    this.height = 40.0,
  });

  final double height;

  @override
  RenderCommandSearch createRenderObject(BuildContext context) {
    return RenderCommandSearch(height: height);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderCommandSearch renderObject,
  ) {
    renderObject.height = height;
  }
}

class RenderCommandSearch extends RenderProxyBox {
  RenderCommandSearch({required double height}) : _height = height;

  double _height;
  set height(double value) {
    if (_height == value) return;
    _height = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    size = constraints.constrain(Size(double.infinity, _height));
    child?.layout(
      BoxConstraints.tight(
        size,
      ).deflate(const EdgeInsets.symmetric(horizontal: 12)),
      parentUsesSize: true,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final rect = offset & size;

    // Background with border
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      Paint()..color = const Color(0xFFFFFFFF),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      Paint()
        ..color = const Color(0xFFDDDDDD)
        ..style = PaintingStyle.stroke,
    );

    super.paint(context, offset);
  }
}
