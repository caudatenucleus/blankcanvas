// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:blankcanvas/src/foundation/status.dart';
import 'control_customization.dart';


/// Customization for Dividers.
class DividerCustomization extends ControlCustomization<DividerControlStatus> {
  const DividerCustomization({
    required super.decoration,
    required super.textStyle, // Usually unused or used for label in splitters
    this.thickness,
    this.indent,
    this.endIndent,
  });

  final double? thickness;
  final double? indent;
  final double? endIndent;
}
