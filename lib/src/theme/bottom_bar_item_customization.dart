// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'control_customization.dart';


/// Customization for BottomBar Item.
class BottomBarItemCustomization
    extends ControlCustomization<BottomBarItemControlStatus> {
  const BottomBarItemCustomization({
    required super.decoration,
    required super.textStyle,
    this.padding,
  });

  final EdgeInsetsGeometry? padding;
}
