// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'mutable_control_status.dart';


/// Status for a Checkbox or Switch.
class ToggleControlStatus extends MutableControlStatus {
  /// Whether the control is currently checked/toggled on.
  /// 0.0 = off, 1.0 = on.
  double get checked => _checked;
  double _checked = 0.0;
  set checked(double value) {
    if (_checked != value) {
      _checked = value;
      notify();
    }
  }
}