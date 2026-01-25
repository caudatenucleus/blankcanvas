// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'control_customization.dart';
import 'color_item_customization.dart';


/// Customization for ColorPickers.
class ColorPickerCustomization
    extends ControlCustomization<ColorPickerControlStatus> {
  const ColorPickerCustomization({
    required super.decoration,
    required super.textStyle,
    required this.itemCustomization,
    this.columns,
    this.spacing,
    this.runSpacing,
    this.padding,
  });

  final ColorItemCustomization itemCustomization;
  final int? columns;
  final double? spacing;
  final double? runSpacing;
  final EdgeInsetsGeometry? padding;

  factory ColorPickerCustomization.simple({
    ColorItemCustomization? itemCustomization,
    double? spacing,
    double? runSpacing,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
    BorderRadius? borderRadius,
  }) {
    return ColorPickerCustomization(
      itemCustomization: itemCustomization ?? ColorItemCustomization.simple(),
      spacing: spacing,
      runSpacing: runSpacing,
      padding: padding ?? const EdgeInsets.all(8),
      decoration: (status) {
        return BoxDecoration(
          color: backgroundColor, // Could be null (transparent)
          borderRadius: borderRadius,
        );
      },
      textStyle: (_) => const TextStyle(),
    );
  }
}
