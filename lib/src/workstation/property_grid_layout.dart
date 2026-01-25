// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// 2-column property inspector layout engine using lowest-level RenderObject APIs.
class PropertyGridLayout extends MultiChildRenderObjectWidget {
  const PropertyGridLayout({
    super.key,
    required super.children,
    this.labelWidth = 120.0,
    this.rowHeight = 32.0,
  });

  final double labelWidth;
  final double rowHeight;

  @override
  RenderPropertyGrid createRenderObject(BuildContext context) {
    return RenderPropertyGrid(labelWidth: labelWidth, rowHeight: rowHeight);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderPropertyGrid renderObject,
  ) {
    renderObject
      ..labelWidth = labelWidth
      ..rowHeight = rowHeight;
  }
}

class PropertyGridParentData extends ContainerBoxParentData<RenderBox> {}

class RenderPropertyGrid extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, PropertyGridParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, PropertyGridParentData> {
  RenderPropertyGrid({double labelWidth = 120.0, double rowHeight = 32.0})
    : _labelWidth = labelWidth,
      _rowHeight = rowHeight;

  double _labelWidth;
  set labelWidth(double val) {
    if (_labelWidth == val) return;
    _labelWidth = val;
    markNeedsLayout();
  }

  double _rowHeight;
  set rowHeight(double val) {
    if (_rowHeight == val) return;
    _rowHeight = val;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! PropertyGridParentData) {
      child.parentData = PropertyGridParentData();
    }
  }

  @override
  void performLayout() {
    final double availableWidth = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : 300.0;

    double y = 0;
    RenderBox? child = firstChild;
    while (child != null) {
      final pd = child.parentData as PropertyGridParentData;

      if (childAfter(child) != null) {
        RenderBox label = child;
        RenderBox value = childAfter(child)!;

        label.layout(
          BoxConstraints.tightFor(width: _labelWidth, height: _rowHeight),
        );
        (label.parentData as PropertyGridParentData).offset = Offset(0, y);

        double valueWidth = (availableWidth - _labelWidth).clamp(
          0,
          double.infinity,
        );
        value.layout(
          BoxConstraints.tightFor(width: valueWidth, height: _rowHeight),
        );
        (value.parentData as PropertyGridParentData).offset = Offset(
          _labelWidth,
          y,
        );

        y += _rowHeight;
        child = childAfter(value);
      } else {
        child.layout(
          BoxConstraints.tightFor(width: availableWidth, height: _rowHeight),
        );
        pd.offset = Offset(0, y);
        y += _rowHeight;
        child = childAfter(child);
      }
    }

    size = constraints.constrain(Size(availableWidth, y));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
