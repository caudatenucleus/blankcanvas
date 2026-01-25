// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'control_customization.dart';


/// Customization for Checkboxes.
class CheckboxCustomization extends ControlCustomization<ToggleControlStatus> {
  const CheckboxCustomization({
    required super.decoration,
    required super.textStyle, // Often unused but kept for consistency or label
    this.size,
  });
  final double? size;

  /// A simple factory for creating a [CheckboxCustomization].
  factory CheckboxCustomization.simple({
    Color? activeColor,
    Color? checkColor,
    Color? disabledColor,
    Color? inactiveColor,
    double? size,
    BorderRadius? borderRadius,
  }) {
    return CheckboxCustomization(
      size: size,
      decoration: (status) {
        final checked = status.checked > 0.5;
        final enabled = status.enabled > 0.5;
        Color color = inactiveColor ?? const Color(0xFFFFFFFF);
        if (!enabled) {
          color = disabledColor ?? const Color(0xFFE0E0E0);
        } else if (checked) {
          color = activeColor ?? const Color(0xFF2196F3);
        }

        return BoxDecoration(
          color: color,
          borderRadius: borderRadius ?? BorderRadius.circular(4),
          border: !checked && enabled
              ? Border.all(color: const Color(0xFF757575))
              : null,
        );
      },
      textStyle: (status) => TextStyle(
        color: checkColor ?? const Color(0xFFFFFFFF),
        fontSize: (size ?? 18) * 0.8,
      ),
    );
  }
}
