// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'control_status.dart';

import 'dart:ui' show lerpDouble;

/// mutable properties, typically driven by an animation controller or strict values.
class MutableControlStatus extends ControlStatus {
  MutableControlStatus({
    double enabled = 1.0,
    double focused = 0.0,
    double hovered = 0.0,
    double active = 0.0,
  }) : _enabled = enabled,
       _focused = focused,
       _hovered = hovered,
       _active = active;

  @override
  double get enabled => _enabled;
  double _enabled;
  set enabled(double value) {
    if (_enabled != value) {
      _enabled = value;
      notify();
    }
  }

  @override
  double get focused => _focused;
  double _focused;
  set focused(double value) {
    if (_focused != value) {
      _focused = value;
      notify();
    }
  }

  @override
  double get hovered => _hovered;
  double _hovered;
  set hovered(double value) {
    if (_hovered != value) {
      _hovered = value;
      notify();
    }
  }

  @override
  double get active => _active;
  double _active;
  set active(double value) {
    if (_active != value) {
      _active = value;
      notify();
    }
  }

  @override
  ControlStatus lerpTo(ControlStatus? other, double t) {
    if (other == null) return this;
    return MutableControlStatus(
      enabled: lerpDouble(enabled, other.enabled, t) ?? enabled,
      focused: lerpDouble(focused, other.focused, t) ?? focused,
      hovered: lerpDouble(hovered, other.hovered, t) ?? hovered,
      active: lerpDouble(active, other.active, t) ?? active,
    );
  }
}
