// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'control_customization.dart';


/// Customization for Toolbar.
class ToolbarCustomization extends ControlCustomization<ControlStatus> {
  const ToolbarCustomization({
    required super.decoration,
    required super.textStyle,
    this.backgroundColor,
  });

  final Color? backgroundColor;

  factory ToolbarCustomization.simple({
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return ToolbarCustomization(
      backgroundColor: backgroundColor ?? const Color(0xFF2196F3),
      decoration: (_) =>
          BoxDecoration(color: backgroundColor ?? const Color(0xFF2196F3)),
      textStyle: (_) => TextStyle(
        color: foregroundColor ?? const Color(0xFFFFFFFF),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
