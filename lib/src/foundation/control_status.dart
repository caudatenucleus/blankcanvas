// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/foundation.dart';

/// Base class for all control status objects.
abstract class ControlStatus {
  /// Whether the control is enabled. 1.0 = fully enabled, 0.0 = disabled.
  double get enabled;

  /// Whether the control has focus. 1.0 = focused, 0.0 = not focused.
  double get focused;

  /// Whether the control is hovered. 1.0 = hovered, 0.0 = not hovered.
  double get hovered;

  /// Whether the control is active (e.g. pressed/selected). 1.0 = active.
  double get active => 0.0;

  /// Linearly interpolate between two statuses.
  ControlStatus lerpTo(ControlStatus? other, double t) => this;

  final List<VoidCallback> _listeners = [];

  /// Adds a listener that will be called when the status changes.
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  /// Removes a listener.
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  /// Notifies all listeners that the status has changed.
  @protected
  void notify() {
    for (final listener in _listeners) {
      listener();
    }
  }
}
