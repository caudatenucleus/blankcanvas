// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'control_customization.dart';


/// Customization for DataTable Rows.
class DataRowCustomization extends ControlCustomization<DataRowControlStatus> {
  const DataRowCustomization({
    required super.decoration,
    required super.textStyle,
  });

  factory DataRowCustomization.simple({
    Color? hoverColor,
    Color? selectedColor,
    TextStyle? textStyle,
  }) {
    return DataRowCustomization(
      decoration: (status) {
        if (status.selected > 0.5) {
          return BoxDecoration(color: selectedColor ?? const Color(0xFFE3F2FD));
        }
        if (status.hovered > 0.5) {
          return BoxDecoration(color: hoverColor ?? const Color(0xFFF5F5F5));
        }
        return const BoxDecoration(color: Color(0x00000000));
      },
      textStyle: (_) => textStyle ?? const TextStyle(),
    );
  }
}
