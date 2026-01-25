// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderTable - Grid-based structured layout engine
// =============================================================================

class _TableCellParentDataPrimitive extends ContainerBoxParentData<RenderBox> {
  int row = 0;
  int column = 0;
}

class TablePrimitive extends MultiChildRenderObjectWidget {
  const TablePrimitive({
    super.key,
    required this.columns,
    super.children = const [],
  });
  final int columns;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderTablePrimitive(columns: columns);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderTablePrimitive renderObject,
  ) {
    renderObject.columns = columns;
  }
}

class RenderTablePrimitive extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _TableCellParentDataPrimitive>,
        RenderBoxContainerDefaultsMixin<
          RenderBox,
          _TableCellParentDataPrimitive
        > {
  RenderTablePrimitive({required int columns}) : _columns = columns;

  int _columns;
  int get columns => _columns;
  set columns(int value) {
    if (_columns != value) {
      _columns = value;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _TableCellParentDataPrimitive) {
      child.parentData = _TableCellParentDataPrimitive();
    }
  }

  @override
  void performLayout() {
    if (_columns <= 0 || firstChild == null) {
      size = constraints.smallest;
      return;
    }

    // Assign row/column indices
    int index = 0;
    RenderBox? child = firstChild;
    while (child != null) {
      final _TableCellParentDataPrimitive pd =
          child.parentData! as _TableCellParentDataPrimitive;
      pd.row = index ~/ _columns;
      pd.column = index % _columns;
      index++;
      child = pd.nextSibling;
    }

    final int rows = (index + _columns - 1) ~/ _columns;
    final double columnWidth = constraints.maxWidth / _columns;

    // Layout cells and compute row heights
    List<double> rowHeights = List.filled(rows, 0.0);
    child = firstChild;
    while (child != null) {
      final _TableCellParentDataPrimitive pd =
          child.parentData! as _TableCellParentDataPrimitive;
      child.layout(
        BoxConstraints.tightFor(width: columnWidth),
        parentUsesSize: true,
      );
      if (child.size.height > rowHeights[pd.row]) {
        rowHeights[pd.row] = child.size.height;
      }
      child = pd.nextSibling;
    }

    // Position cells
    child = firstChild;
    while (child != null) {
      final _TableCellParentDataPrimitive pd =
          child.parentData! as _TableCellParentDataPrimitive;
      double y = 0;
      for (int r = 0; r < pd.row; r++) {
        y += rowHeights[r];
      }
      pd.offset = Offset(pd.column * columnWidth, y);
      child = pd.nextSibling;
    }

    double totalHeight = 0;
    for (final h in rowHeights) {
      totalHeight += h;
    }
    size = constraints.constrain(Size(constraints.maxWidth, totalHeight));
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
