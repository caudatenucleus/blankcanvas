// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'control_customization.dart';


/// Customization for Dropdown.
class DropdownCustomization extends ControlCustomization<ControlStatus> {
  const DropdownCustomization({
    required super.decoration,
    required super.textStyle,
    this.menuDecoration,
    this.itemDecoration,
    this.itemTextStyle,
  });

  final Decoration? menuDecoration;
  final Decoration? itemDecoration;
  final TextStyle? itemTextStyle;

  factory DropdownCustomization.simple({
    Color? backgroundColor,
    Color? menuBackgroundColor,
    Color? borderColor,
    Color? textColor,
    Color? itemTextColor,
    BorderRadius? borderRadius,
  }) {
    return DropdownCustomization(
      menuDecoration: BoxDecoration(
        color: menuBackgroundColor ?? const Color(0xFFFFFFFF),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(4),
      ),
      itemDecoration: const BoxDecoration(), // Usually transparent
      itemTextStyle: TextStyle(
        color: itemTextColor ?? const Color(0xFF000000),
        fontSize: 14,
      ),
      decoration: (status) {
        return BoxDecoration(
          color: backgroundColor ?? const Color(0xFFFAFAFA),
          border: Border.all(color: borderColor ?? const Color(0xFFBDBDBD)),
          borderRadius: borderRadius ?? BorderRadius.circular(4),
        );
      },
      textStyle: (status) =>
          TextStyle(color: textColor ?? const Color(0xFF000000), fontSize: 14),
    );
  }
}
