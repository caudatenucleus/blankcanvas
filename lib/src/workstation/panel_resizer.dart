// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'package:blankcanvas/src/theme/workstation_theme.dart';

/// A resize handle primitive using lowest-level RenderObject APIs.
class PanelResizer extends LeafRenderObjectWidget {
  const PanelResizer({super.key, this.axis = Axis.vertical, this.onResize});

  final Axis axis;
  final ValueChanged<double>? onResize;

  @override
  RenderPanelResizer createRenderObject(BuildContext context) {
    return RenderPanelResizer(
      axis: axis,
      onResize: onResize,
      theme: WorkstationTheme.of(context),
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderPanelResizer renderObject,
  ) {
    renderObject
      ..axis = axis
      ..onResize = onResize
      ..theme = WorkstationTheme.of(context);
  }
}

class RenderPanelResizer extends RenderBox {
  RenderPanelResizer({
    required Axis axis,
    ValueChanged<double>? onResize,
    required WorkstationThemeData theme,
  }) : _axis = axis,
       _onResize = onResize,
       _theme = theme {
    _pan = PanGestureRecognizer()..onUpdate = _handlePanUpdate;
  }

  Axis _axis;
  set axis(Axis value) {
    if (_axis == value) return;
    _axis = value;
    markNeedsLayout();
  }

  ValueChanged<double>? _onResize;
  set onResize(ValueChanged<double>? value) => _onResize = value;

  WorkstationThemeData _theme;
  set theme(WorkstationThemeData value) {
    if (_theme == value) return;
    _theme = value;
    markNeedsPaint();
  }

  late PanGestureRecognizer _pan;

  void _handlePanUpdate(DragUpdateDetails details) {
    _onResize?.call(
      _axis == Axis.vertical ? details.delta.dy : details.delta.dx,
    );
  }

  @override
  void performLayout() {
    size = constraints.constrain(
      _axis == Axis.horizontal
          ? const Size(4, double.infinity)
          : const Size(double.infinity, 4),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.canvas.drawRect(
      offset & size,
      Paint()..color = _theme.resizerColor,
    );
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _pan.addPointer(event);
    }
  }
}
