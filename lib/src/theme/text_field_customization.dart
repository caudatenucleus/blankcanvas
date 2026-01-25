// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'control_customization.dart';


/// Customization specific to TextFields.
class TextFieldCustomization extends ControlCustomization<ControlStatus> {
  const TextFieldCustomization({
    required super.decoration,
    required super.textStyle,
    this.cursorColor,
  });

  final Color? cursorColor;

  /// A simple factory for creating a [TextFieldCustomization].
  factory TextFieldCustomization.simple({
    Color? backgroundColor,
    Color? focusedColor,
    Color? borderColor,
    Color? focusedBorderColor,
    Color? cursorColor,
    Color? textColor,
    BorderRadius? borderRadius,
    TextStyle? textStyle,
    EdgeInsetsGeometry? padding,
  }) {
    return TextFieldCustomization(
      cursorColor: cursorColor,
      decoration: (status) {
        final isFocused = status.focused > 0.0;
        final color = isFocused
            ? (focusedColor ?? backgroundColor)
            : backgroundColor;
        final border = isFocused
            ? Border.all(
                color: focusedBorderColor ?? const Color(0xFF2196F3),
                width: 2,
              )
            : Border.all(color: borderColor ?? const Color(0xFF9E9E9E));

        return BoxDecoration(
          color: color,
          border: border,
          borderRadius: borderRadius ?? BorderRadius.circular(4),
        );
      },
      textStyle: (status) =>
          (textStyle ?? const TextStyle()).copyWith(color: textColor),
    );
  }
}
