// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';

/// This is a simplified Directionality lookup helper if strict basic widgets is the rule.
class Directionality extends InheritedWidget {
  const Directionality({
    super.key,
    required this.textDirection,
    required super.child,
  });

  final TextDirection textDirection;

  static TextDirection of(BuildContext context) {
    final Directionality? widget = context
        .dependOnInheritedWidgetOfExactType<Directionality>();
    if (widget == null) {
      throw FlutterError('No Directionality widget found.');
    }
    return widget.textDirection;
  }

  static TextDirection? maybeOf(BuildContext context) {
    final Directionality? widget = context
        .dependOnInheritedWidgetOfExactType<Directionality>();
    return widget?.textDirection;
  }

  @override
  bool updateShouldNotify(Directionality oldWidget) =>
      textDirection != oldWidget.textDirection;
}
