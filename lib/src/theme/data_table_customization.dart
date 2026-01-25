// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'control_customization.dart';
import 'data_row_customization.dart';


/// Customization for DataTable.
class DataTableCustomization extends ControlCustomization<ControlStatus> {
  const DataTableCustomization({
    required super.decoration,
    required super.textStyle,
    required this.rowCustomization,
    this.headerTextStyle,
    this.headerDecoration,
    this.padding,
    this.dividerColor,
  });

  final DataRowCustomization rowCustomization;
  final TextStyle? headerTextStyle;
  final BoxDecoration? headerDecoration;
  final EdgeInsetsGeometry? padding;
  final Color? dividerColor;

  factory DataTableCustomization.simple({
    DataRowCustomization? rowCustomization,
    BoxDecoration? headerDecoration,
    TextStyle? headerTextStyle,
    EdgeInsetsGeometry? padding,
    Color? dividerColor,
  }) {
    return DataTableCustomization(
      rowCustomization: rowCustomization ?? DataRowCustomization.simple(),
      headerDecoration:
          headerDecoration ?? const BoxDecoration(color: Color(0xFFEEEEEE)),
      headerTextStyle:
          headerTextStyle ?? const TextStyle(fontWeight: FontWeight.bold),
      padding: padding,
      dividerColor: dividerColor ?? const Color(0xFFE0E0E0),
      decoration: (_) => const BoxDecoration(), // Usually container decoration
      textStyle: (_) => const TextStyle(),
    );
  }
}
