// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderTableBorder - Grid-line painting logic
// =============================================================================

class TableBorderPrimitive {
  const TableBorderPrimitive({
    this.top = BorderSide.none,
    this.right = BorderSide.none,
    this.bottom = BorderSide.none,
    this.left = BorderSide.none,
    this.horizontalInside = BorderSide.none,
    this.verticalInside = BorderSide.none,
  });

  final BorderSide top;
  final BorderSide right;
  final BorderSide bottom;
  final BorderSide left;
  final BorderSide horizontalInside;
  final BorderSide verticalInside;

  TableBorder toTableBorder() {
    return TableBorder(
      top: top,
      right: right,
      bottom: bottom,
      left: left,
      horizontalInside: horizontalInside,
      verticalInside: verticalInside,
    );
  }
}
