// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'control_customization.dart';


/// Customization specific to Buttons.
class ButtonCustomization extends ControlCustomization<ControlStatus> {
  const ButtonCustomization({
    required super.decoration,
    required super.textStyle,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  /// A simple factory for creating a [ButtonCustomization] with common properties.
  factory ButtonCustomization.simple({
    Color? backgroundColor,
    Color? hoverColor,
    Color? pressColor,
    Color? disabledColor,
    Color? foregroundColor,
    BorderRadius? borderRadius,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    TextStyle? textStyle,
  }) {
    return ButtonCustomization(
      width: width,
      height: height,
      decoration: (status) {
        Color? color = backgroundColor;
        if (status.enabled < 0.5) {
          color = disabledColor ?? const Color(0xFFE0E0E0);
        } else if (status.hovered > 0.0) {
          // Simple interpolation logic could go here, but for 'simple' we just switch
          color = hoverColor ?? backgroundColor?.withValues(alpha: 0.8);
        }
        // Active state could be checked here if exposed in status, or inferred.

        return BoxDecoration(
          color: color,
          borderRadius: borderRadius ?? BorderRadius.circular(4),
        );
      },
      textStyle: (status) {
        return (textStyle ?? const TextStyle()).copyWith(
          color: foregroundColor,
        );
      },
    );
  }
}
