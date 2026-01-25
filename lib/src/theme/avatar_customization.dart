// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'control_customization.dart';


/// Customization for Avatar.
class AvatarCustomization extends ControlCustomization<ControlStatus> {
  const AvatarCustomization({
    required super.decoration,
    required super.textStyle,
    this.size,
    this.statusColor,
  });

  final double? size;
  final Color? statusColor;

  factory AvatarCustomization.simple({
    double? size,
    Color? backgroundColor,
    Color? statusColor,
    TextStyle? textStyle,
    BorderRadius? borderRadius,
  }) {
    return AvatarCustomization(
      size: size ?? 48,
      statusColor: statusColor ?? const Color(0xFF4CAF50),
      decoration: (status) => BoxDecoration(
        color: backgroundColor ?? const Color(0xFFEEEEEE),
        borderRadius: borderRadius ?? BorderRadius.circular(24),
      ),
      textStyle: (status) =>
          textStyle ??
          const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF757575),
          ),
    );
  }
}

/// Customization for Stepper.
