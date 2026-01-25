// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'mutable_control_status.dart';


/// Status for a Slider.
class SliderControlStatus extends MutableControlStatus {
  /// The normalized value of the slider (0.0 to 1.0 generally, or map range).
  /// For visual purposes, usually normalized. context might carry min/max.
  double get value => _value;
  double _value = 0.0;
  set value(double v) {
    if (_value != v) {
      _value = v;
      notify();
    }
  }

  // Sliders might have an 'active' dragging state which is separate from focused/hovered
  double get dragging => _dragging;
  double _dragging = 0.0;
  set dragging(double v) {
    if (_dragging != v) {
      _dragging = v;
      notify();
    }
  }
}