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

/// Customization for Checkboxes.
class CheckboxCustomization extends ControlCustomization<ToggleControlStatus> {
  const CheckboxCustomization({
    required super.decoration,
    required super.textStyle, // Often unused but kept for consistency or label
    this.size,
  });
  final double? size;
}

/// Customization for Switches.
class SwitchCustomization extends ControlCustomization<ToggleControlStatus> {
  const SwitchCustomization({
    required super.decoration,
    required super.textStyle,
    this.width,
    this.height,
  });
  final double? width;
  final double? height;
}

/// Customization for Radio buttons.
class RadioCustomization extends ControlCustomization<RadioControlStatus> {
  const RadioCustomization({
    required super.decoration,
    required super.textStyle,
    this.size,
  });
  final double? size;
}

/// Customization for Sliders.
class SliderCustomization extends ControlCustomization<SliderControlStatus> {
  const SliderCustomization({
    required super.decoration,
    required super.textStyle,
    this.trackHeight,
    this.thumbSize,
  });

  final double? trackHeight;
  final double? thumbSize;
}

/// Customization for Progress Indicators.
class ProgressCustomization
    extends ControlCustomization<ProgressControlStatus> {
  const ProgressCustomization({
    required super.decoration,
    required super.textStyle,
    this.height,
  });
  final double? height; // For linear progress
}

/// Customization for Cards.
class CardCustomization extends ControlCustomization<CardControlStatus> {
  const CardCustomization({
    required super.decoration,
    required super.textStyle,
  });
}

/// Customization for Dialogs.
class DialogCustomization extends ControlCustomization<CardControlStatus> {
  const DialogCustomization({
    required super.decoration,
    required super.textStyle,
    this.modalBarrierColor,
  });

  final Color? modalBarrierColor;
}

/// Customization for Scrollbars.
class ScrollbarCustomization
    extends ControlCustomization<ScrollbarControlStatus> {
  const ScrollbarCustomization({
    required super.decoration, // Used for the THUMB
    required super.textStyle,
    this.trackDecoration, // Used for the TRACK
    this.thickness,
    this.thumbMinLength,
  });

  final Decoration Function(ScrollbarControlStatus status)? trackDecoration;
  final double? thickness;
  final double? thumbMinLength;
}

/// Customization for Tabs/Segmented Controls.
class TabCustomization extends ControlCustomization<TabControlStatus> {
  const TabCustomization({
    required super.decoration,
    required super.textStyle,
    this.padding,
  });

  final EdgeInsetsGeometry? padding;
}

/// Customization for Menus (Container).
class MenuCustomization extends ControlCustomization<CardControlStatus> {
  const MenuCustomization({
    required super.decoration,
    required super.textStyle,
  });
}

/// Customization for Menu Items.
class MenuItemCustomization
    extends ControlCustomization<MenuItemControlStatus> {
  const MenuItemCustomization({
    required super.decoration,
    required super.textStyle,
    this.padding,
  });

  final EdgeInsetsGeometry? padding;
}

/// Customization for BottomBar.
class BottomBarCustomization
    extends ControlCustomization<BottomBarControlStatus> {
  const BottomBarCustomization({
    required super.decoration,
    required super.textStyle,
    this.height,
  });

  final double? height;
}

/// Customization for BottomBar Item.
class BottomBarItemCustomization
    extends ControlCustomization<BottomBarItemControlStatus> {
  const BottomBarItemCustomization({
    required super.decoration,
    required super.textStyle,
    this.padding,
  });

  final EdgeInsetsGeometry? padding;
}

/// Customization for Drawers.
class DrawerCustomization extends ControlCustomization<DrawerControlStatus> {
  const DrawerCustomization({
    required super.decoration,
    required super.textStyle,
    this.width,
    this.modalBarrierColor,
  });

  final double? width;
  final Color? modalBarrierColor;
}

/// Customization for Badges.
class BadgeCustomization extends ControlCustomization<BadgeControlStatus> {
  const BadgeCustomization({
    required super.decoration,
    required super.textStyle,
    this.padding,
    this.alignment,
  });

  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? alignment;
}

/// Customization for Dividers.
class DividerCustomization extends ControlCustomization<DividerControlStatus> {
  const DividerCustomization({
    required super.decoration,
    required super.textStyle, // Usually unused or used for label in splitters
    this.thickness,
    this.indent,
    this.endIndent,
  });

  final double? thickness;
  final double? indent;
  final double? endIndent;
}

/// Customization for Tooltips.
class TooltipCustomization extends ControlCustomization<TooltipControlStatus> {
  const TooltipCustomization({
    required super.decoration,
    required super.textStyle,
    this.padding,
    this.margin,
    this.waitDuration,
    this.showDuration,
  });

  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Duration? waitDuration;
  final Duration? showDuration;
}
