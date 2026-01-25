// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:blankcanvas/src/theme/workstation_theme.dart';

/// A workstation-style side drawer primitive using lowest-level RenderObject APIs.
class SideDrawer extends SingleChildRenderObjectWidget {
  const SideDrawer({super.key, required super.child, this.width = 250.0});

  final double width;

  @override
  RenderSideDrawer createRenderObject(BuildContext context) {
    return RenderSideDrawer(width: width, theme: WorkstationTheme.of(context));
  }

  @override
  void updateRenderObject(BuildContext context, RenderSideDrawer renderObject) {
    renderObject
      ..width = width
      ..theme = WorkstationTheme.of(context);
  }
}

class RenderSideDrawer extends RenderProxyBox {
  RenderSideDrawer({required double width, required WorkstationThemeData theme})
    : _width = width,
      _theme = theme;

  double _width;
  set width(double value) {
    if (_width == value) return;
    _width = value;
    markNeedsLayout();
  }

  WorkstationThemeData _theme;
  set theme(WorkstationThemeData value) {
    if (_theme == value) return;
    _theme = value;
    markNeedsPaint();
  }

  @override
  void performLayout() {
    BoxConstraints innerConstraints = constraints.tighten(width: _width);
    child?.layout(innerConstraints, parentUsesSize: true);
    size = constraints.constrain(Size(_width, double.infinity));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final rect = offset & size;

    // Background with shadow
    final paint = Paint()..color = _theme.panelBackground;
    canvas.drawRect(rect, paint);

    // Simplified shadow
    canvas.drawRect(
      Rect.fromLTWH(offset.dx + size.width, offset.dy, 2, size.height),
      Paint()..color = _theme.panelShadow,
    );

    super.paint(context, offset);
  }
}
