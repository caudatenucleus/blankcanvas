// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.


// =============================================================================
// RenderFlexOverflowDetection - Intrinsic-size exceeding logic
// =============================================================================

class FlexOverflowDetectionPrimitive {
  const FlexOverflowDetectionPrimitive();

  bool hasOverflow(double allocatedSize, double childrenSize) {
    return childrenSize > allocatedSize;
  }

  double computeOverflowAmount(double allocatedSize, double childrenSize) {
    return (childrenSize - allocatedSize).clamp(0.0, double.infinity);
  }
}
