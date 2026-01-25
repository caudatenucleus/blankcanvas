// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'control_customization.dart';


/// Customization for Tooltips.
class TooltipCustomization extends ControlCustomization<TooltipControlStatus> {
  const TooltipCustomization({
    required super.decoration,
    required super.textStyle,
    this.padding,
    this.margin,
    this.waitDuration,
    this.showDuration,
  });

  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Duration? waitDuration;
  final Duration? showDuration;
}
