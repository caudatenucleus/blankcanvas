import 'package:flutter/foundation.dart';

/// Represents the status of a control, e.g. whether it is enabled, focused, etc.
///
/// This does not correspond to the [State] class of the widget, but rather
/// the logical state of the control's interaction model.
abstract class ControlStatus with ChangeNotifier {
  ControlStatus();

  /// Whether the control is currently enabled.
  ///
  /// Represented as a double from 0.0 (disabled) to 1.0 (enabled).
  double get enabled;

  /// Whether the control currently has input focus.
  ///
  /// Represented as a double from 0.0 (unfocused) to 1.0 (focused).
  double get focused;

  /// Whether the control is currently being hovered over by a pointer.
  ///
  /// Represented as a double from 0.0 (not hovered) to 1.0 (hovered).
  double get hovered;

  // Helpers for subclasses to notify listeners when values change.
  void notify() => notifyListeners();
}

/// A concrete implementation of [ControlStatus] that manages the values as
/// mutable properties, typically driven by an animation controller or strict values.
class MutableControlStatus extends ControlStatus {
  @override
  double get enabled => _enabled;
  double _enabled = 1.0;
  set enabled(double value) {
    if (_enabled != value) {
      _enabled = value;
      notify();
    }
  }

  @override
  double get focused => _focused;
  double _focused = 0.0;
  set focused(double value) {
    if (_focused != value) {
      _focused = value;
      notify();
    }
  }

  @override
  double get hovered => _hovered;
  double _hovered = 0.0;
  set hovered(double value) {
    if (_hovered != value) {
      _hovered = value;
      notify();
    }
  }
}
