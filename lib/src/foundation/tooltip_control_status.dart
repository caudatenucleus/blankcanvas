// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'mutable_control_status.dart';


/// Status for a Tooltip.
class TooltipControlStatus extends MutableControlStatus {
  /// Whether the tooltip is currently visible/active.
  double get visible => _visible;
  double _visible = 0.0;
  set visible(double v) {
    if (_visible != v) {
      _visible = v;
      notify();
    }
  }
}

/// Status for a DatePicker container.