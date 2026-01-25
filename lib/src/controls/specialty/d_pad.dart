// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'render_d_pad.dart';

enum DPadDirection { up, down, left, right, center }

/// A directional pad (D-Pad) controller.
class DPad extends LeafRenderObjectWidget {
  const DPad({
    super.key,
    this.onDirection,
    this.size = 140.0,
    this.activeColor = const Color(0xFF2196F3),
    this.inactiveColor = const Color(0xFF333333),
    this.tag,
  });

  final void Function(DPadDirection direction)? onDirection;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final String? tag;

  @override
  RenderDPad createRenderObject(BuildContext context) {
    return RenderDPad(
      onDirection: onDirection,
      dpadSize: size,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderDPad renderObject) {
    renderObject
      ..onDirection = onDirection
      ..dpadSize = size
      ..activeColor = activeColor
      ..inactiveColor = inactiveColor;
  }
}
