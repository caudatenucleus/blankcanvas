// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'monitor_data.dart';
import 'render_multi_monitor_canvas.dart';


class MultiMonitorCanvasPrimitive extends SingleChildRenderObjectWidget {
  const MultiMonitorCanvasPrimitive({
    super.key,
    super.child,
    required this.monitors,
    this.monitorColor = const Color(0xFF2D2D2D),
    this.primaryColor = const Color(0xFF007AFF),
    this.borderColor = const Color(0xFF3D3D3D),
    this.gapBetweenMonitors = 4.0,
  });

  final List<MonitorData> monitors;
  final Color monitorColor;
  final Color primaryColor;
  final Color borderColor;
  final double gapBetweenMonitors;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderMultiMonitorCanvas(
      monitors: monitors,
      monitorColor: monitorColor,
      primaryColor: primaryColor,
      borderColor: borderColor,
      gapBetweenMonitors: gapBetweenMonitors,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderMultiMonitorCanvas renderObject,
  ) {
    renderObject
      ..monitors = monitors
      ..monitorColor = monitorColor
      ..primaryColor = primaryColor
      ..borderColor = borderColor
      ..gapBetweenMonitors = gapBetweenMonitors;
  }
}
