// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'mutable_control_status.dart';


/// Status for a Stepper Step.
class StepControlStatus extends MutableControlStatus {
  /// 1.0 if active (currently focused step), 0.0 otherwise.
  @override
  double get active => _active;
  double _active = 0.0;

  @override
  set active(double v) {
    if (_active != v) {
      _active = v;
      notify();
    }
  }

  /// 1.0 if completed (past step), 0.0 otherwise.
  double get completed => _completed;
  double _completed = 0.0;

  set completed(double v) {
    if (_completed != v) {
      _completed = v;
      notify();
    }
  }
}