// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'mutable_control_status.dart';


/// Status for an Accordion Panel Header.
class AccordionControlStatus extends MutableControlStatus {
  /// 1.0 if expanded, 0.0 if collapsed.
  double get expanded => _expanded;
  double _expanded = 0.0;

  set expanded(double v) {
    if (_expanded != v) {
      _expanded = v;
      notify();
    }
  }
}