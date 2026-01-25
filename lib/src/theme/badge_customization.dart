// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'control_customization.dart';


/// Customization for Badges.
class BadgeCustomization extends ControlCustomization<BadgeControlStatus> {
  const BadgeCustomization({
    required super.decoration,
    required super.textStyle,
    this.padding,
    this.alignment,
  });

  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? alignment;
}
