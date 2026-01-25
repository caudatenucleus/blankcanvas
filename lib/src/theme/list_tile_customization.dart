// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'control_customization.dart';


/// Customization for ListTile.
class ListTileCustomization extends ControlCustomization<ControlStatus> {
  const ListTileCustomization({
    required super.decoration,
    required super.textStyle,
    this.subtitleTextStyle,
    this.leadingPadding,
    this.trailingPadding,
    this.contentPadding,
  });

  final TextStyle? subtitleTextStyle;
  final EdgeInsetsGeometry? leadingPadding;
  final EdgeInsetsGeometry? trailingPadding;
  final EdgeInsetsGeometry? contentPadding;

  factory ListTileCustomization.simple({
    Color? backgroundColor,
    Color? hoverColor,
    TextStyle? titleStyle,
    TextStyle? subtitleStyle,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return ListTileCustomization(
      decoration: (status) {
        if (status.hovered > 0.5) {
          return BoxDecoration(color: hoverColor ?? const Color(0xFFF5F5F5));
        }
        return BoxDecoration(color: backgroundColor ?? const Color(0x00000000));
      },
      textStyle: (status) =>
          titleStyle ??
          const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      subtitleTextStyle:
          subtitleStyle ??
          const TextStyle(fontSize: 14, color: Color(0xFF757575)),
      contentPadding:
          contentPadding ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}
