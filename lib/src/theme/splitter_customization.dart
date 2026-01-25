// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'control_customization.dart';


/// Customization for Splitter.
class SplitterCustomization extends ControlCustomization<ControlStatus> {
  const SplitterCustomization({
    required super.decoration,
    required super.textStyle,
    this.dividerColor,
    this.dividerThickness,
  });

  final Color? dividerColor;
  final double? dividerThickness;

  factory SplitterCustomization.simple({
    Color? dividerColor,
    double? dividerThickness,
  }) {
    return SplitterCustomization(
      dividerColor: dividerColor ?? const Color(0xFFE0E0E0),
      dividerThickness: dividerThickness ?? 8.0,
      decoration: (_) => const BoxDecoration(),
      textStyle: (_) => const TextStyle(),
    );
  }
}
