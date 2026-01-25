// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'control_customization.dart';


/// Customization for Date Cells in a DatePicker.
class DateCellCustomization
    extends ControlCustomization<DateCellControlStatus> {
  const DateCellCustomization({
    required super.decoration,
    required super.textStyle,
    this.padding,
    this.alignment,
  });

  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? alignment;

  factory DateCellCustomization.simple({
    EdgeInsetsGeometry? padding,
    AlignmentGeometry? alignment,
    Color? selectedColor,
    Color? todayColor,
    TextStyle? textStyle,
  }) {
    return DateCellCustomization(
      padding: padding,
      alignment: alignment,
      decoration: (status) {
        if (status.selected > 0.5) {
          return BoxDecoration(
            color: selectedColor ?? const Color(0xFF2196F3),
            shape: BoxShape.circle,
          );
        }
        if (status.today > 0.5) {
          return BoxDecoration(
            border: Border.all(color: todayColor ?? const Color(0xFF2196F3)),
            shape: BoxShape.circle,
          );
        }
        return const BoxDecoration();
      },
      textStyle: (status) {
        final base = textStyle ?? const TextStyle();
        if (status.selected > 0.5) {
          return base.copyWith(color: const Color(0xFFFFFFFF));
        }
        return base;
      },
    );
  }
}
