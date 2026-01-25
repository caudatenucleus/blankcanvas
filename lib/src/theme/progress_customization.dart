// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:blankcanvas/src/foundation/status.dart';
import 'control_customization.dart';


/// Customization for Progress Indicators.
class ProgressCustomization
    extends ControlCustomization<ProgressControlStatus> {
  const ProgressCustomization({
    required super.decoration,
    required super.textStyle,
    this.height,
  });
  final double? height; // For linear progress
}
