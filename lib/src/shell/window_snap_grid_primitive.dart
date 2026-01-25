// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'render_window_snap_grid.dart';


class WindowSnapGridPrimitive extends LeafRenderObjectWidget {
  const WindowSnapGridPrimitive({
    super.key,
    this.columns = 3,
    this.rows = 2,
    this.gridColor = const Color(0x40007AFF),
    this.hoveredZone = -1,
    this.showLabels = false,
  });

  final int columns;
  final int rows;
  final Color gridColor;
  final int hoveredZone;
  final bool showLabels;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderWindowSnapGrid(
      columns: columns,
      rows: rows,
      gridColor: gridColor,
      hoveredZone: hoveredZone,
      showLabels: showLabels,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderWindowSnapGrid renderObject,
  ) {
    renderObject
      ..columns = columns
      ..rows = rows
      ..gridColor = gridColor
      ..hoveredZone = hoveredZone
      ..showLabels = showLabels;
  }
}
