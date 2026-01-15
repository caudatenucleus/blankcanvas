import 'package:flutter/widgets.dart';
import '../foundation/status.dart';

/// A customization for a control, providing builders for its visual properties
/// based on its status.
class ControlCustomization<S extends ControlStatus> {
  const ControlCustomization({
    required this.decoration,
    required this.textStyle,
  });

  /// Builds a [Decoration] for the control based on the given status.
  final Decoration Function(S status) decoration;

  /// Builds a [TextStyle] for the control based on the given status.
  final TextStyle Function(S status) textStyle;
}

/// Customization specific to Buttons.
class ButtonCustomization extends ControlCustomization<ControlStatus> {
  const ButtonCustomization({
    required super.decoration,
    required super.textStyle,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;
}

/// Customization specific to TextFields.
class TextFieldCustomization extends ControlCustomization<ControlStatus> {
  const TextFieldCustomization({
    required super.decoration,
    required super.textStyle,
    this.cursorColor,
  });

  final Color? cursorColor;
}
