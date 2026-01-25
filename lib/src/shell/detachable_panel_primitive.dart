// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'render_detachable_panel.dart';


class DetachablePanelPrimitive extends SingleChildRenderObjectWidget {
  const DetachablePanelPrimitive({
    super.key,
    super.child,
    this.titleBarHeight = 24.0,
    this.titleBarColor = const Color(0xFF2D2D2D),
    this.isDetached = false,
    this.showDetachButton = true,
  });

  final double titleBarHeight;
  final Color titleBarColor;
  final bool isDetached;
  final bool showDetachButton;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderDetachablePanel(
      titleBarHeight: titleBarHeight,
      titleBarColor: titleBarColor,
      isDetached: isDetached,
      showDetachButton: showDetachButton,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderDetachablePanel renderObject,
  ) {
    renderObject
      ..titleBarHeight = titleBarHeight
      ..titleBarColor = titleBarColor
      ..isDetached = isDetached
      ..showDetachButton = showDetachButton;
  }
}
