// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'control_customization.dart';


/// Customization for Switches.
class SwitchCustomization extends ControlCustomization<ToggleControlStatus> {
  const SwitchCustomization({
    required super.decoration,
    required super.textStyle,
    this.width,
    this.height,
  });
  final double? width;
  final double? height;

  /// A simple factory for creating a [SwitchCustomization].
  factory SwitchCustomization.simple({
    Color? activeColor,
    Color? activeTrackColor,
    Color? inactiveThumbColor,
    Color? inactiveTrackColor,
    double? width,
    double? height,
  }) {
    return SwitchCustomization(
      width: width,
      height: height,
      decoration: (status) {
        final checked = status.checked > 0.5;
        Color color = checked
            ? (activeTrackColor ?? const Color(0xFFBBDEFB))
            : (inactiveTrackColor ?? const Color(0xFFE0E0E0));
        return BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        );
      },
      textStyle: (status) {
        final checked = status.checked > 0.5;
        return TextStyle(
          color: checked
              ? (activeColor ?? const Color(0xFF2196F3))
              : (inactiveThumbColor ?? const Color(0xFFFFFFFF)),
        );
      },
    );
  }
}
