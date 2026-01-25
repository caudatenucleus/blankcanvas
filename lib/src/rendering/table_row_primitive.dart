// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';

// =============================================================================
// RenderTableRow - Horizontal cell grouping logic
// =============================================================================

class TableRowPrimitive {
  const TableRowPrimitive({this.key, this.decoration, required this.children});

  final LocalKey? key;
  final Decoration? decoration;
  final List<Widget> children;

  TableRow toTableRow() {
    return TableRow(key: key, decoration: decoration, children: children);
  }
}
