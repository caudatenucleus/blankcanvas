// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderWrapAlignment - Cross-axis alignment orchestrator
// =============================================================================

class WrapAlignmentPrimitive {
  const WrapAlignmentPrimitive({
    this.alignment = WrapAlignment.start,
    this.crossAxisAlignment = WrapCrossAlignment.start,
  });

  final WrapAlignment alignment;
  final WrapCrossAlignment crossAxisAlignment;

  double computeLeadingSpace(double freeSpace, int childCount) {
    switch (alignment) {
      case WrapAlignment.start:
        return 0.0;
      case WrapAlignment.end:
        return freeSpace;
      case WrapAlignment.center:
        return freeSpace / 2.0;
      case WrapAlignment.spaceBetween:
        return 0.0;
      case WrapAlignment.spaceAround:
        return childCount > 0 ? freeSpace / childCount / 2.0 : 0.0;
      case WrapAlignment.spaceEvenly:
        return childCount > 0 ? freeSpace / (childCount + 1) : 0.0;
    }
  }
}
