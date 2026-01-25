// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:blankcanvas/src/foundation/status.dart';


/// based on its status.
class ControlCustomization<S extends ControlStatus> {
  const ControlCustomization({
    required this.decoration,
    required this.textStyle,
  });

  /// Builds a [Decoration] for the control based on the given status.
  final Decoration Function(S status) decoration;

  /// Builds a [TextStyle] for the control based on the given status.
  final TextStyle Function(S status) textStyle;
}
