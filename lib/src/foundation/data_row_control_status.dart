// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'mutable_control_status.dart';


/// Status for a DataTable (DataGrid) Row.
class DataRowControlStatus extends MutableControlStatus {
  double get selected => _selected;
  double _selected = 0.0;

  set selected(double v) {
    if (_selected != v) {
      _selected = v;
      notify();
    }
  }
}