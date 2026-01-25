// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'control_customization.dart';


/// Customization for Header.
class HeaderCustomization extends ControlCustomization<ControlStatus> {
  const HeaderCustomization({
    required super.decoration,
    required super.textStyle,
    this.elevation,
    this.backgroundColor,
  });

  final double? elevation;
  final Color? backgroundColor;

  factory HeaderCustomization.simple({
    Color? backgroundColor,
    Color? foregroundColor,
    double? elevation,
  }) {
    return HeaderCustomization(
      backgroundColor: backgroundColor ?? const Color(0xFF2196F3),
      elevation: elevation ?? 4.0,
      decoration: (_) => BoxDecoration(
        color: backgroundColor ?? const Color(0xFF2196F3),
        boxShadow: elevation != null && elevation > 0
            ? [BoxShadow(color: const Color(0x26000000), blurRadius: elevation)]
            : null,
      ),
      textStyle: (_) => TextStyle(
        color: foregroundColor ?? const Color(0xFFFFFFFF),
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
