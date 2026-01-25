// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'control_customization.dart';


/// Customization for Carousel.
class CarouselCustomization extends ControlCustomization<ControlStatus> {
  const CarouselCustomization({
    required super.decoration,
    required super.textStyle,
    this.indicatorColor,
    this.indicatorSelectedColor,
  });
  final Color? indicatorColor;
  final Color? indicatorSelectedColor;

  factory CarouselCustomization.simple({
    Color? indicatorColor,
    Color? indicatorSelectedColor,
  }) {
    return CarouselCustomization(
      indicatorColor: indicatorColor ?? const Color(0xFFE0E0E0),
      indicatorSelectedColor: indicatorSelectedColor ?? const Color(0xFF2196F3),
      decoration: (_) => const BoxDecoration(),
      textStyle: (_) => const TextStyle(),
    );
  }
}
