import 'package:flutter/rendering.dart';

/// The status of a control.
class ControlStatus {
  const ControlStatus({
    this.isHovered = false,
    this.isPressed = false,
    this.isFocused = false,
    this.isDisabled = false,
  });

  final bool isHovered;
  final bool isPressed;
  final bool isFocused;
  final bool isDisabled;

  ControlStatus copyWith({
    bool? isHovered,
    bool? isPressed,
    bool? isFocused,
    bool? isDisabled,
  }) {
    return ControlStatus(
      isHovered: isHovered ?? this.isHovered,
      isPressed: isPressed ?? this.isPressed,
      isFocused: isFocused ?? this.isFocused,
      isDisabled: isDisabled ?? this.isDisabled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ControlStatus &&
        other.isHovered == isHovered &&
        other.isPressed == isPressed &&
        other.isFocused == isFocused &&
        other.isDisabled == isDisabled;
  }

  @override
  int get hashCode => Object.hash(isHovered, isPressed, isFocused, isDisabled);
}

/// Interface for RenderObjects that can receive status updates from a parent CanvasControl.
abstract class StatusAwareRenderObject extends RenderObject {
  set controlStatus(ControlStatus status);
}
