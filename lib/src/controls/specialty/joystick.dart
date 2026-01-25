// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'render_joystick.dart';


/// A game controller joystick.
class Joystick extends LeafRenderObjectWidget {
  const Joystick({
    super.key,
    this.onMove,
    this.onEnd,
    this.size = 150.0,
    this.backgroundColor = const Color(0xFF333333),
    this.handleColor = const Color(0xFF2196F3),
    this.tag,
  });

  final void Function(Offset direction)? onMove;
  final VoidCallback? onEnd;
  final double size;
  final Color backgroundColor;
  final Color handleColor;
  final String? tag;

  @override
  RenderJoystick createRenderObject(BuildContext context) {
    return RenderJoystick(
      onMove: onMove,
      onEnd: onEnd,
      joystickSize: size,
      backgroundColor: backgroundColor,
      handleColor: handleColor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderJoystick renderObject) {
    renderObject
      ..onMove = onMove
      ..onEnd = onEnd
      ..joystickSize = size
      ..backgroundColor = backgroundColor
      ..handleColor = handleColor;
  }
}
