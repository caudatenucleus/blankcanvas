// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'window_state_data.dart';
import 'render_multi_window_sync.dart';


class MultiWindowSyncPrimitive extends LeafRenderObjectWidget {
  const MultiWindowSyncPrimitive({
    super.key,
    required this.windows,
    required this.activeWindowId,
    this.windowColor = const Color(0xFF2D2D2D),
    this.activeColor = const Color(0xFF007AFF),
    this.borderColor = const Color(0xFF3D3D3D),
  });

  final List<WindowStateData> windows;
  final String activeWindowId;
  final Color windowColor;
  final Color activeColor;
  final Color borderColor;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderMultiWindowSync(
      windows: windows,
      activeWindowId: activeWindowId,
      windowColor: windowColor,
      activeColor: activeColor,
      borderColor: borderColor,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderMultiWindowSync renderObject,
  ) {
    renderObject
      ..windows = windows
      ..activeWindowId = activeWindowId
      ..windowColor = windowColor
      ..activeColor = activeColor
      ..borderColor = borderColor;
  }
}
