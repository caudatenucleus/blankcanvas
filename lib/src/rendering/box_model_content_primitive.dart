// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.


// =============================================================================
// RenderBoxModelContent - Intrinsic-content sizing atom
// =============================================================================

class BoxModelContentPrimitive {
  const BoxModelContentPrimitive({
    this.minIntrinsicWidth,
    this.maxIntrinsicWidth,
    this.minIntrinsicHeight,
    this.maxIntrinsicHeight,
  });

  final double? minIntrinsicWidth;
  final double? maxIntrinsicWidth;
  final double? minIntrinsicHeight;
  final double? maxIntrinsicHeight;

  /// Compute intrinsic width for a given height
  double computeIntrinsicWidth(
    double height,
    double Function(double) childIntrinsic,
  ) {
    return minIntrinsicWidth ?? childIntrinsic(height);
  }

  /// Compute intrinsic height for a given width
  double computeIntrinsicHeight(
    double width,
    double Function(double) childIntrinsic,
  ) {
    return minIntrinsicHeight ?? childIntrinsic(width);
  }
}
