// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'mutable_control_status.dart';


/// Status for a Scrollbar.
class ScrollbarControlStatus extends MutableControlStatus {
  /// Whether the user is dragging the scrollbar thumb.
  double get dragging => _dragging;
  double _dragging = 0.0;
  set dragging(double v) {
    if (_dragging != v) {
      _dragging = v;
      notify();
    }
  }
}