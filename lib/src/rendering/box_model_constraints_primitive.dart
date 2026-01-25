// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderBoxModelConstraints - Tight/Loose/Bounded logic
// =============================================================================

enum BoxModelConstraintType { tight, loose, bounded, unbounded }

class BoxModelConstraintsPrimitive {
  const BoxModelConstraintsPrimitive({
    this.type = BoxModelConstraintType.loose,
    this.minWidth = 0.0,
    this.maxWidth = double.infinity,
    this.minHeight = 0.0,
    this.maxHeight = double.infinity,
  });

  final BoxModelConstraintType type;
  final double minWidth;
  final double maxWidth;
  final double minHeight;
  final double maxHeight;

  /// Create tight constraints (exact size)
  factory BoxModelConstraintsPrimitive.tight(Size size) {
    return BoxModelConstraintsPrimitive(
      type: BoxModelConstraintType.tight,
      minWidth: size.width,
      maxWidth: size.width,
      minHeight: size.height,
      maxHeight: size.height,
    );
  }

  /// Create loose constraints (0 to max)
  factory BoxModelConstraintsPrimitive.loose(Size size) {
    return BoxModelConstraintsPrimitive(
      type: BoxModelConstraintType.loose,
      minWidth: 0.0,
      maxWidth: size.width,
      minHeight: 0.0,
      maxHeight: size.height,
    );
  }

  /// Convert to Flutter BoxConstraints
  BoxConstraints toBoxConstraints() {
    return BoxConstraints(
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,
    );
  }

  /// Check if constraints are satisfied
  bool isSatisfiedBy(Size size) {
    return size.width >= minWidth &&
        size.width <= maxWidth &&
        size.height >= minHeight &&
        size.height <= maxHeight;
  }

  /// Constrain a size to fit within bounds
  Size constrain(Size size) {
    return Size(
      size.width.clamp(minWidth, maxWidth),
      size.height.clamp(minHeight, maxHeight),
    );
  }
}
