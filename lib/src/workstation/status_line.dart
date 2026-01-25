// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:blankcanvas/src/theme/workstation_theme.dart';

/// Strict-height footer status line using lowest-level RenderObject APIs.
class StatusLine extends MultiChildRenderObjectWidget {
  const StatusLine({super.key, required this.message, this.actions})
    : super(children: actions ?? const []);

  final String message;
  final List<Widget>? actions;

  @override
  RenderStatusLine createRenderObject(BuildContext context) {
    return RenderStatusLine(
      message: message,
      theme: WorkstationTheme.of(context),
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderStatusLine renderObject) {
    renderObject
      ..message = message
      ..theme = WorkstationTheme.of(context);
  }
}

class RenderStatusLine extends RenderBox
    with
        ContainerRenderObjectMixin<
          RenderBox,
          ContainerBoxParentData<RenderBox>
        >,
        RenderBoxContainerDefaultsMixin<
          RenderBox,
          ContainerBoxParentData<RenderBox>
        > {
  RenderStatusLine({
    required String message,
    required WorkstationThemeData theme,
  }) : _message = message,
       _theme = theme;

  String _message;
  set message(String value) {
    if (_message == value) return;
    _message = value;
    markNeedsPaint();
  }

  WorkstationThemeData _theme;
  set theme(WorkstationThemeData value) {
    if (_theme == value) return;
    _theme = value;
    markNeedsPaint();
  }

  @override
  void performLayout() {
    size = constraints.constrain(const Size(double.infinity, 24));
    // Layout actions from right to left (Placeholder)
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.drawRect(
      offset & size,
      Paint()..color = _theme.statusLineBackground,
    );

    // Paint message (Placeholder)
    defaultPaint(context, offset);
  }
}
