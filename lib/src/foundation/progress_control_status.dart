// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'mutable_control_status.dart';


/// Status for a Progress Indicator.
class ProgressControlStatus extends MutableControlStatus {
  /// The fractional value of progress (0.0 to 1.0) if determinant.
  /// If null, it is indeterminate.
  double? get progress => _progress;
  double? _progress;
  set progress(double? v) {
    if (_progress != v) {
      _progress = v;
      notify();
    }
  }

  /// Whether the progress is indeterminate. 1.0 if indeterminate, 0.0 if determinate.
  /// Useful for switching decorations.
  double get indeterminate => _progress == null ? 1.0 : 0.0;
}