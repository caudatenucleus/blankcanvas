// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// A viewport HUD overlay primitive using lowest-level RenderObject APIs.
class ViewportHUD extends SingleChildRenderObjectWidget {
  const ViewportHUD({super.key, required super.child, required this.overlay});

  final Widget overlay;

  @override
  RenderViewportHUD createRenderObject(BuildContext context) {
    return RenderViewportHUD();
  }
}

class RenderViewportHUD extends RenderProxyBox {
  // HUD logic using custom painting and overlay layering
}
