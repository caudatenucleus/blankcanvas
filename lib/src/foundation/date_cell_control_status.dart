// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'mutable_control_status.dart';


/// Status for a single Date Cell in the picker.
class DateCellControlStatus extends MutableControlStatus {
  /// Whether the date is currently selected.
  double get selected => _selected;
  double _selected = 0.0;

  set selected(double v) {
    if (_selected != v) {
      _selected = v;
      notify();
    }
  }

  /// Whether the date is today.
  double get today => _today;
  double _today = 0.0;

  set today(double v) {
    if (_today != v) {
      _today = v;
      notify();
    }
  }

  /// Whether the date is in the currently displayed month.
  /// 1.0 = current month, 0.0 = adjacent month (often grayed out).
  double get currentMonth => _currentMonth;
  double _currentMonth = 1.0;

  set currentMonth(double v) {
    if (_currentMonth != v) {
      _currentMonth = v;
      notify();
    }
  }
}