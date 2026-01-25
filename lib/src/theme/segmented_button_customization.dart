// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'control_customization.dart';


/// Customization for SegmentedButton.
class SegmentedButtonCustomization
    extends ControlCustomization<RadioControlStatus> {
  const SegmentedButtonCustomization({
    required super.decoration,
    required super.textStyle,
    this.selectedDecoration,
    this.selectedTextStyle,
    this.padding,
    this.borderRadius,
  });

  final Decoration Function(RadioControlStatus)? selectedDecoration;
  final TextStyle Function(RadioControlStatus)? selectedTextStyle;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  factory SegmentedButtonCustomization.simple({
    Color? backgroundColor,
    Color? selectedColor,
    Color? borderColor,
    Color? textColor,
    Color? selectedTextColor,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
  }) {
    return SegmentedButtonCustomization(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      decoration: (status) {
        return BoxDecoration(
          color: backgroundColor ?? const Color(0xFFFFFFFF),
          border: Border.all(color: borderColor ?? const Color(0xFF2196F3)),
        );
      },
      selectedDecoration: (status) =>
          BoxDecoration(color: selectedColor ?? const Color(0xFFE3F2FD)),
      textStyle: (status) {
        return TextStyle(
          color: textColor ?? const Color(0xFF000000),
          fontSize: 14,
        );
      },
      selectedTextStyle: (status) {
        return TextStyle(
          color: selectedTextColor ?? const Color(0xFF2196F3),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        );
      },
    );
  }
}
