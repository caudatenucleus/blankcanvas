// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderStackFit - Constraint-propagation logic
// =============================================================================

class StackFitPrimitive {
  const StackFitPrimitive({this.fit = StackFit.loose});

  final StackFit fit;

  BoxConstraints computeChildConstraints(
    BoxConstraints constraints,
    bool isPositioned,
  ) {
    if (isPositioned) {
      return constraints;
    }
    switch (fit) {
      case StackFit.loose:
        return constraints.loosen();
      case StackFit.expand:
        return BoxConstraints.tight(constraints.biggest);
      case StackFit.passthrough:
        return constraints;
    }
  }
}
