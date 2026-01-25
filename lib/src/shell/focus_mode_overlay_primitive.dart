// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'render_focus_mode_overlay.dart';


class FocusModeOverlayPrimitive extends SingleChildRenderObjectWidget {
  const FocusModeOverlayPrimitive({
    super.key,
    super.child,
    this.isActive = false,
    this.dimAmount = 0.7,
    this.dimColor = const Color(0xFF000000),
    this.focusRect,
  });

  final bool isActive;
  final double dimAmount;
  final Color dimColor;
  final Rect? focusRect;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderFocusModeOverlay(
      isActive: isActive,
      dimAmount: dimAmount,
      dimColor: dimColor,
      focusRect: focusRect,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderFocusModeOverlay renderObject,
  ) {
    renderObject
      ..isActive = isActive
      ..dimAmount = dimAmount
      ..dimColor = dimColor
      ..focusRect = focusRect;
  }
}
