// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

/// A panel collapse state and animation primitive using lowest-level RenderObject APIs.
class PanelCollapse extends SingleChildRenderObjectWidget {
  const PanelCollapse({
    super.key,
    required super.child,
    required this.isCollapsed,
    this.axis = Axis.vertical,
  });

  final bool isCollapsed;
  final Axis axis;

  @override
  RenderPanelCollapse createRenderObject(BuildContext context) {
    return RenderPanelCollapse(isCollapsed: isCollapsed, axis: axis);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderPanelCollapse renderObject,
  ) {
    renderObject
      ..isCollapsed = isCollapsed
      ..axis = axis;
  }
}

class RenderPanelCollapse extends RenderProxyBox implements TickerProvider {
  RenderPanelCollapse({required bool isCollapsed, required Axis axis})
    : _isCollapsed = isCollapsed,
      _axis = axis;

  bool _isCollapsed;
  set isCollapsed(bool value) {
    if (_isCollapsed == value) return;
    _isCollapsed = value;
    // Animation logic would go here using a Ticker
    markNeedsLayout();
  }

  Axis _axis;
  set axis(Axis value) {
    if (_axis == value) return;
    _axis = value;
    markNeedsLayout();
  }

  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);

  @override
  void performLayout() {
    if (child == null) {
      size = constraints.smallest;
      return;
    }

    child!.layout(constraints.loosen(), parentUsesSize: true);
    size = constraints.constrain(child!.size);
    if (_isCollapsed) {
      size = _axis == Axis.vertical
          ? Size(size.width, 0)
          : Size(0, size.height);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_isCollapsed) return;
    super.paint(context, offset);
  }
}
