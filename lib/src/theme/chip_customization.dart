// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'control_customization.dart';


/// Customization for Chip.
class ChipCustomization extends ControlCustomization<RadioControlStatus> {
  const ChipCustomization({
    required super.decoration,
    required super.textStyle,
    this.padding,
    this.deleteIconColor,
  });

  final EdgeInsetsGeometry? padding;
  final Color? deleteIconColor;

  factory ChipCustomization.simple({
    Color? backgroundColor,
    Color? selectedColor,
    Color? disabledColor,
    Color? textColor,
    Color? selectedTextColor,
    Color? deleteIconColor,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
  }) {
    return ChipCustomization(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      deleteIconColor: deleteIconColor ?? const Color(0xFF757575),
      decoration: (status) {
        final selected = status.selected > 0.5;
        final enabled = status.enabled > 0.5;
        Color color = backgroundColor ?? const Color(0xFFE0E0E0);
        if (!enabled) {
          color = disabledColor ?? const Color(0xFFF5F5F5);
        } else if (selected) {
          color =
              selectedColor ??
              const Color(0xFFE0E0E0); // Usually darker or distinct
        }
        return BoxDecoration(
          color: color,
          borderRadius: borderRadius ?? BorderRadius.circular(16),
        );
      },
      textStyle: (status) {
        final selected = status.selected > 0.5;
        return TextStyle(
          color: selected
              ? (selectedTextColor ?? const Color(0xFF000000))
              : (textColor ?? const Color(0xFF000000)),
          fontSize: 14,
        );
      },
    );
  }
}
