// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderFlexCrossAxisPositioning - Cross-axis alignment
// =============================================================================

class FlexCrossAxisPositioningPrimitive {
  const FlexCrossAxisPositioningPrimitive({
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  final CrossAxisAlignment crossAxisAlignment;

  double computeChildCrossAxisOffset(
    double crossAxisSize,
    double childCrossAxisExtent,
  ) {
    switch (crossAxisAlignment) {
      case CrossAxisAlignment.start:
      case CrossAxisAlignment.baseline:
        return 0.0;
      case CrossAxisAlignment.end:
        return crossAxisSize - childCrossAxisExtent;
      case CrossAxisAlignment.center:
        return (crossAxisSize - childCrossAxisExtent) / 2.0;
      case CrossAxisAlignment.stretch:
        return 0.0;
    }
  }
}
