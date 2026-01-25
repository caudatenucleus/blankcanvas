// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'control_customization.dart';


/// Customization for Scrollbars.
class ScrollbarCustomization
    extends ControlCustomization<ScrollbarControlStatus> {
  const ScrollbarCustomization({
    required super.decoration, // Used for the THUMB
    required super.textStyle,
    this.trackDecoration, // Used for the TRACK
    this.thickness,
    this.thumbMinLength,
  });

  final Decoration Function(ScrollbarControlStatus status)? trackDecoration;
  final double? thickness;
  final double? thumbMinLength;
}
