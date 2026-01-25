// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'window_group_tab_data.dart';
import 'render_window_group_tabs.dart';


class WindowGroupTabsPrimitive extends LeafRenderObjectWidget {
  const WindowGroupTabsPrimitive({
    super.key,
    required this.groups,
    required this.activeGroupId,
    this.tabHeight = 28.0,
    this.tabMinWidth = 80.0,
    this.backgroundColor = const Color(0xFF1E1E1E),
    this.activeTabColor = const Color(0xFF3D3D3D),
    this.inactiveTabColor = const Color(0xFF2D2D2D),
    this.textColor = const Color(0xFFCCCCCC),
  });

  final List<WindowGroupTabData> groups;
  final String activeGroupId;
  final double tabHeight;
  final double tabMinWidth;
  final Color backgroundColor;
  final Color activeTabColor;
  final Color inactiveTabColor;
  final Color textColor;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderWindowGroupTabs(
      groups: groups,
      activeGroupId: activeGroupId,
      tabHeight: tabHeight,
      tabMinWidth: tabMinWidth,
      backgroundColor: backgroundColor,
      activeTabColor: activeTabColor,
      inactiveTabColor: inactiveTabColor,
      textColor: textColor,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderWindowGroupTabs renderObject,
  ) {
    renderObject
      ..groups = groups
      ..activeGroupId = activeGroupId
      ..tabHeight = tabHeight
      ..tabMinWidth = tabMinWidth
      ..backgroundColor = backgroundColor
      ..activeTabColor = activeTabColor
      ..inactiveTabColor = inactiveTabColor
      ..textColor = textColor;
  }
}
