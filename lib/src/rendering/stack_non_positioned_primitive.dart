// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderStackNonPositioned - Loose-child alignment logic
// =============================================================================

class StackNonPositionedPrimitive {
  const StackNonPositionedPrimitive({
    this.alignment = AlignmentDirectional.topStart,
  });

  final AlignmentGeometry alignment;

  Offset computeChildOffset(
    Size stackSize,
    Size childSize,
    TextDirection textDirection,
  ) {
    final Alignment resolved = alignment.resolve(textDirection);
    return resolved.alongOffset(stackSize - childSize as Offset);
  }
}
