// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'control_customization.dart';


/// Customization for Color Items in a ColorPicker.
class ColorItemCustomization
    extends ControlCustomization<ColorItemControlStatus> {
  const ColorItemCustomization({
    required super.decoration,
    required super.textStyle, // Usually unused
    this.size,
    this.margin,
  });

  final Size? size;
  final EdgeInsetsGeometry? margin;

  factory ColorItemCustomization.simple({
    Size? size,
    EdgeInsetsGeometry? margin,
    Color? borderColor,
    Color? selectedBorderColor,
    double? borderWidth,
  }) {
    return ColorItemCustomization(
      size: size ?? const Size(32, 32),
      margin: margin ?? const EdgeInsets.all(4),
      decoration: (status) {
        final selected = status.selected > 0.5;
        // Note: The widget adds the 'color'. Here we just provide shape/border.
        return BoxDecoration(
          shape: BoxShape.circle,
          border: selected
              ? Border.all(
                  color: selectedBorderColor ?? const Color(0xFF000000),
                  width: borderWidth ?? 2,
                )
              : (borderColor != null
                    ? Border.all(color: borderColor, width: borderWidth ?? 1)
                    : null),
        );
      },
      textStyle: (_) => const TextStyle(),
    );
  }
}
