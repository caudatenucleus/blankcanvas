// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'control_customization.dart';


/// Customization for Dialogs.
class DialogCustomization extends ControlCustomization<CardControlStatus> {
  const DialogCustomization({
    required super.decoration,
    required super.textStyle,
    this.modalBarrierColor,
  });

  final Color? modalBarrierColor;
}
