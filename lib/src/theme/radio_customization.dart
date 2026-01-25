// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'control_customization.dart';


/// Customization for Radio buttons.
class RadioCustomization extends ControlCustomization<RadioControlStatus> {
  const RadioCustomization({
    required super.decoration,
    required super.textStyle,
    this.size,
  });
  final double? size;

  /// A simple factory for creating a [RadioCustomization].
  factory RadioCustomization.simple({
    Color? activeColor,
    Color? inactiveColor,
    Color? disabledColor,
    double? size,
  }) {
    return RadioCustomization(
      size: size,
      decoration: (status) {
        final selected = status.selected > 0.5;
        final enabled = status.enabled > 0.5;
        Color color = inactiveColor ?? const Color(0xFF757575);
        if (!enabled) {
          color = disabledColor ?? const Color(0xFFE0E0E0);
        } else if (selected) {
          color = activeColor ?? const Color(0xFF2196F3);
        }

        return BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        );
      },
      textStyle: (status) {
        final selected = status.selected > 0.5;
        final enabled = status.enabled > 0.5;
        Color color = inactiveColor ?? const Color(0xFF757575);
        if (!enabled) {
          color = disabledColor ?? const Color(0xFFE0E0E0);
        } else if (selected) {
          color = activeColor ?? const Color(0xFF2196F3);
        }
        return TextStyle(color: color);
      },
    );
  }
}
