// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'mutable_control_status.dart';


/// Status for a Tree Item.
class TreeItemControlStatus extends MutableControlStatus {
  /// Whether the item is expanded (showing children).
  double get expanded => _expanded;
  double _expanded = 0.0;

  set expanded(double v) {
    if (_expanded != v) {
      _expanded = v;
      notify();
    }
  }

  /// Whether the item is selected.
  double get selected => _selected;
  double _selected = 0.0;

  set selected(double v) {
    if (_selected != v) {
      _selected = v;
      notify();
    }
  }
}