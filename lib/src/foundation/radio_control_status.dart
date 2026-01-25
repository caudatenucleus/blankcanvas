// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'mutable_control_status.dart';


/// Status for a Radio button.
class RadioControlStatus extends MutableControlStatus {
  /// Whether the radio is currently selected.
  /// 0.0 = unselected, 1.0 = selected.
  double get selected => _selected;
  double _selected = 0.0;
  set selected(double value) {
    if (_selected != value) {
      _selected = value;
      notify();
    }
  }
}