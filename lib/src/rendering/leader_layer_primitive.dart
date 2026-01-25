// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderLeaderLayer - Link-target coordinate engine
// =============================================================================

class LeaderLayerPrimitive extends SingleChildRenderObjectWidget {
  const LeaderLayerPrimitive({super.key, required this.link, super.child});
  final LayerLink link;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderLeaderLayerPrimitive(link: link);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderLeaderLayerPrimitive renderObject,
  ) {
    renderObject.link = link;
  }
}

class RenderLeaderLayerPrimitive extends RenderLeaderLayer {
  RenderLeaderLayerPrimitive({required super.link});
}
