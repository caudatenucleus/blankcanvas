// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderSliverList - Linear scrollable list engine
// =============================================================================

class SliverListPrimitive extends SliverMultiBoxAdaptorWidget {
  const SliverListPrimitive({super.key, required super.delegate});

  @override
  RenderSliverListPrimitive createRenderObject(BuildContext context) {
    final element = context as SliverMultiBoxAdaptorElement;
    return RenderSliverListPrimitive(childManager: element);
  }
}

class RenderSliverListPrimitive extends RenderSliverList {
  RenderSliverListPrimitive({required super.childManager});
}
