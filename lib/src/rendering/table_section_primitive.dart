// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'table_row_primitive.dart';

// =============================================================================
// RenderTableSection - Header/Body/Footer segmentation (conceptual)
// =============================================================================

// Note: Flutter's Table does not natively support sections.
// This is a conceptual wrapper for organizing table rows.

class TableSectionPrimitive {
  const TableSectionPrimitive({
    required this.rows,
    this.isHeader = false,
    this.isFooter = false,
  });

  final List<TableRowPrimitive> rows;
  final bool isHeader;
  final bool isFooter;
}
