// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderFlexMainAxisPositioning - Main-axis distribution
// =============================================================================

// Note: This is a conceptual primitive. Flutter's Flex uses MainAxisAlignment enum.
// This helper encapsulates the alignment logic.

class FlexMainAxisPositioningPrimitive {
  const FlexMainAxisPositioningPrimitive({
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
  });

  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;

  double computeLeadingSpace(double freeSpace, int childCount) {
    switch (mainAxisAlignment) {
      case MainAxisAlignment.start:
        return 0.0;
      case MainAxisAlignment.end:
        return freeSpace;
      case MainAxisAlignment.center:
        return freeSpace / 2.0;
      case MainAxisAlignment.spaceBetween:
        return 0.0;
      case MainAxisAlignment.spaceAround:
        return childCount > 0 ? freeSpace / childCount / 2.0 : 0.0;
      case MainAxisAlignment.spaceEvenly:
        return childCount > 0 ? freeSpace / (childCount + 1) : 0.0;
    }
  }

  double computeBetweenSpace(double freeSpace, int childCount) {
    if (childCount <= 1) return 0.0;
    switch (mainAxisAlignment) {
      case MainAxisAlignment.start:
      case MainAxisAlignment.end:
      case MainAxisAlignment.center:
        return 0.0;
      case MainAxisAlignment.spaceBetween:
        return freeSpace / (childCount - 1);
      case MainAxisAlignment.spaceAround:
        return freeSpace / childCount;
      case MainAxisAlignment.spaceEvenly:
        return freeSpace / (childCount + 1);
    }
  }
}
