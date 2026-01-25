// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderFlexBaselinePositioning - Text-baseline sync
// =============================================================================

class FlexBaselinePositioningPrimitive {
  const FlexBaselinePositioningPrimitive({this.textBaseline});

  final TextBaseline? textBaseline;

  // Returns the baseline offset for alignment
  double? computeBaselineOffset(
    double? childBaseline,
    double childHeight,
    double lineHeight,
  ) {
    if (textBaseline == null || childBaseline == null) return null;
    return lineHeight - childBaseline;
  }
}
