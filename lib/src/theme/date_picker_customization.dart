// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'control_customization.dart';
import 'date_cell_customization.dart';


/// Customization for DatePickers.
class DatePickerCustomization
    extends ControlCustomization<DatePickerControlStatus> {
  const DatePickerCustomization({
    required super.decoration,
    required super.textStyle,
    required this.dayCustomization,
    this.headerTextStyle,
    this.weekdayTextStyle,
    this.cellPadding,
    this.headerPadding,
    this.columnSpacing,
    this.rowSpacing,
  });

  final DateCellCustomization dayCustomization;
  final TextStyle? headerTextStyle;
  final TextStyle? weekdayTextStyle;
  final EdgeInsetsGeometry? cellPadding;
  final EdgeInsetsGeometry? headerPadding;
  final double? columnSpacing;
  final double? rowSpacing;

  factory DatePickerCustomization.simple({
    DateCellCustomization? dayCustomization,
    TextStyle? headerTextStyle,
    TextStyle? weekdayTextStyle,
    EdgeInsetsGeometry? cellPadding,
    EdgeInsetsGeometry? headerPadding,
    double? columnSpacing,
    double? rowSpacing,
  }) {
    return DatePickerCustomization(
      dayCustomization: dayCustomization ?? DateCellCustomization.simple(),
      headerTextStyle: headerTextStyle,
      weekdayTextStyle: weekdayTextStyle,
      cellPadding: cellPadding,
      headerPadding: headerPadding,
      columnSpacing: columnSpacing,
      rowSpacing: rowSpacing,
      decoration: (_) => const BoxDecoration(),
      textStyle: (_) => const TextStyle(),
    );
  }
}
