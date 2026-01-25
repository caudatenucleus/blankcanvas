// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:blankcanvas/src/foundation/status.dart';
import 'control_customization.dart';


/// Customization for Sliders.
class SliderCustomization extends ControlCustomization<SliderControlStatus> {
  const SliderCustomization({
    required super.decoration,
    required super.textStyle,
    this.trackHeight,
    this.thumbSize,
  });

  final double? trackHeight;
  final double? thumbSize;
}
