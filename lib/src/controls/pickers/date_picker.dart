// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:blankcanvas/src/theme/theme.dart';
import 'render_date_picker.dart';

/// A date picker widget built using RenderObject.
class DatePicker extends LeafRenderObjectWidget {
  const DatePicker({
    super.key,
    required this.firstDate,
    required this.lastDate,
    required this.selectedDate,
    required this.onChanged,
    this.tag,
  });

  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onChanged;
  final String? tag;

  @override
  RenderDatePicker createRenderObject(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization = customizations.getDatePicker(tag);

    return RenderDatePicker(
      selectedDate: selectedDate,
      onChanged: onChanged,
      firstDate: firstDate,
      lastDate: lastDate,
      tag: tag,
      customization: customization,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderDatePicker renderObject) {
    final customizations = CustomizedTheme.of(context);
    final customization = customizations.getDatePicker(tag);

    renderObject
      ..selectedDate = selectedDate
      ..onChanged = onChanged
      ..firstDate = firstDate
      ..lastDate = lastDate
      ..tag = tag
      ..customization = customization;
  }
}
