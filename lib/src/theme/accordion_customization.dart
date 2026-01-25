// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'control_customization.dart';


/// Customization for Accordion.
class AccordionCustomization
    extends ControlCustomization<AccordionControlStatus> {
  const AccordionCustomization({
    required super.decoration,
    required super.textStyle,
    this.contentDecoration,
    this.contentPadding,
    this.headerPadding,
  });

  final Decoration? contentDecoration;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? headerPadding;

  factory AccordionCustomization.simple({
    Color? expandedColor,
    Color? collapsedColor,
    Color? contentBackgroundColor,
    EdgeInsetsGeometry? headerPadding,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return AccordionCustomization(
      headerPadding: headerPadding ?? const EdgeInsets.all(16),
      contentPadding: contentPadding ?? const EdgeInsets.all(16),
      contentDecoration: BoxDecoration(
        color: contentBackgroundColor ?? const Color(0xFFFAFAFA),
        border: const Border(top: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      decoration: (status) {
        // Header decoration
        final expanded = status.expanded > 0.5;
        return BoxDecoration(
          color: expanded
              ? (expandedColor ?? const Color(0xFFE3F2FD))
              : (collapsedColor ?? const Color(0xFFFFFFFF)),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        );
      },
      textStyle: (_) => const TextStyle(fontWeight: FontWeight.bold),
    );
  }
}
