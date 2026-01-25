// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'control_customization.dart';


/// Customization for Ratings.
class RatingsCustomization extends ControlCustomization<ControlStatus> {
  const RatingsCustomization({
    required super.decoration, // Container decoration
    required super.textStyle, // Unused
    this.starColor,
    this.emptyStarColor,
  });

  final Color? starColor;
  final Color? emptyStarColor;

  factory RatingsCustomization.simple({
    Color? starColor,
    Color? emptyStarColor,
  }) {
    return RatingsCustomization(
      starColor: starColor ?? const Color(0xFFFFC107),
      emptyStarColor: emptyStarColor ?? const Color(0xFFE0E0E0),
      decoration: (_) => const BoxDecoration(),
      textStyle: (_) => const TextStyle(),
    );
  }
}
