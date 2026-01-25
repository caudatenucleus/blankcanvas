// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderTableColumn - Cell-span and weighting logic
// =============================================================================

class TableColumnPrimitive {
  const TableColumnPrimitive({this.width = const FlexColumnWidth()});

  final TableColumnWidth width;
}
