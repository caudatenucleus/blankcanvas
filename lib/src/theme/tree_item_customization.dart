// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'control_customization.dart';


/// Customization for Tree Items.
class TreeItemCustomization
    extends ControlCustomization<TreeItemControlStatus> {
  const TreeItemCustomization({
    required super.decoration,
    required super.textStyle,
    this.indent,
    this.padding,
  });

  final double? indent; // Indentation per level
  final EdgeInsetsGeometry? padding;

  factory TreeItemCustomization.simple({
    double? indent,
    EdgeInsetsGeometry? padding,
    Color? selectedColor,
    Color? hoverColor,
    Color? textColor,
  }) {
    return TreeItemCustomization(
      indent: indent ?? 20.0,
      padding:
          padding ?? const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: (status) {
        final selected = status.selected > 0.5;
        final hovered = status.hovered > 0.5;
        Color color = const Color(0x00000000);
        if (selected) {
          color = selectedColor ?? const Color(0xFFE3F2FD);
        } else if (hovered) {
          color = hoverColor ?? const Color(0xFFF5F5F5);
        }

        return BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        );
      },
      textStyle: (status) =>
          TextStyle(color: textColor ?? const Color(0xFF000000)),
    );
  }
}
