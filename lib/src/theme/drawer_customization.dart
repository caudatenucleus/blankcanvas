// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'control_customization.dart';


/// Customization for Drawers.
class DrawerCustomization extends ControlCustomization<DrawerControlStatus> {
  const DrawerCustomization({
    required super.decoration,
    required super.textStyle,
    this.width,
    this.modalBarrierColor,
  });

  final double? width;
  final Color? modalBarrierColor;
}
