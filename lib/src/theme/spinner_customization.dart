// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'control_customization.dart';


/// Customization for Spinner.
class SpinnerCustomization extends ControlCustomization<ProgressControlStatus> {
  const SpinnerCustomization({
    required super.decoration,
    required super.textStyle,
    this.color,
    this.strokeWidth,
  });

  final Color? color;
  final double? strokeWidth;

  factory SpinnerCustomization.simple({Color? color, double? strokeWidth}) {
    return SpinnerCustomization(
      color: color ?? const Color(0xFF2196F3),
      strokeWidth: strokeWidth ?? 4.0,
      decoration: (_) => const BoxDecoration(),
      textStyle: (_) => const TextStyle(),
    );
  }
}
