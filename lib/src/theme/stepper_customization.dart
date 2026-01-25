// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'control_customization.dart';


class StepperCustomization extends ControlCustomization<StepControlStatus> {
  const StepperCustomization({
    required super.decoration, // Decoration for the step circle/indicator
    required super.textStyle,
    this.connectorColor,
    this.completedColor,
    this.activeColor,
    this.inactiveColor,
    this.padding,
  });

  final Color? connectorColor;
  final Color? completedColor;
  final Color? activeColor;
  final Color? inactiveColor;
  final EdgeInsetsGeometry? padding;

  factory StepperCustomization.simple({
    Color? activeColor,
    Color? completedColor,
    Color? inactiveColor,
    Color? connectorColor,
    EdgeInsetsGeometry? padding,
  }) {
    return StepperCustomization(
      activeColor: activeColor,
      completedColor: completedColor,
      inactiveColor: inactiveColor,
      connectorColor: connectorColor ?? const Color(0xFFE0E0E0),
      padding: padding,
      decoration: (status) {
        // This is for the numeric indicator circle usually
        final active = status.active > 0.5;
        final completed = status.completed > 0.5;
        Color c = inactiveColor ?? const Color(0xFFE0E0E0);
        if (completed) {
          c = completedColor ?? const Color(0xFF4CAF50);
        } else if (active) {
          c = activeColor ?? const Color(0xFF2196F3);
        }

        return BoxDecoration(color: c, shape: BoxShape.circle);
      },
      textStyle: (status) {
        return const TextStyle(color: Color(0xFFFFFFFF));
      },
    );
  }
}
