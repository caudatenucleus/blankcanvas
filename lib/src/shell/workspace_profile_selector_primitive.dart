// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'workspace_profile_data.dart';
import 'render_workspace_profile_selector.dart';


class WorkspaceProfileSelectorPrimitive extends LeafRenderObjectWidget {
  const WorkspaceProfileSelectorPrimitive({
    super.key,
    required this.profiles,
    required this.selectedProfileId,
    this.itemHeight = 32.0,
    this.backgroundColor = const Color(0xFF1E1E1E),
    this.selectedColor = const Color(0xFF007AFF),
    this.hoverColor = const Color(0xFF2D2D2D),
    this.textColor = const Color(0xFFCCCCCC),
  });

  final List<WorkspaceProfileData> profiles;
  final String selectedProfileId;
  final double itemHeight;
  final Color backgroundColor;
  final Color selectedColor;
  final Color hoverColor;
  final Color textColor;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderWorkspaceProfileSelector(
      profiles: profiles,
      selectedProfileId: selectedProfileId,
      itemHeight: itemHeight,
      backgroundColor: backgroundColor,
      selectedColor: selectedColor,
      hoverColor: hoverColor,
      textColor: textColor,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderWorkspaceProfileSelector renderObject,
  ) {
    renderObject
      ..profiles = profiles
      ..selectedProfileId = selectedProfileId
      ..itemHeight = itemHeight
      ..backgroundColor = backgroundColor
      ..selectedColor = selectedColor
      ..hoverColor = hoverColor
      ..textColor = textColor;
  }
}
