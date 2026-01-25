// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:blankcanvas/src/theme/customization.dart';
import 'package:blankcanvas/src/theme/theme.dart';
import 'render_toggle_icon.dart';


class ToggleIconWidget extends LeafRenderObjectWidget {
  const ToggleIconWidget({super.key, 
    required this.isExpanded,
    required this.customization,
  });
  final bool isExpanded;
  final TreeItemCustomization customization;

  @override
  RenderToggleIcon createRenderObject(BuildContext context) =>
      RenderToggleIcon(isExpanded: isExpanded, customization: customization);

  @override
  void updateRenderObject(BuildContext context, RenderToggleIcon renderObject) {
    renderObject
      ..isExpanded = isExpanded
      ..customization = customization;
  }
}
