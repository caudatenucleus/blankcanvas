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

  /// A simple factory for creating a [ButtonCustomization] with common properties.
  factory ButtonCustomization.simple({
    Color? backgroundColor,
    Color? hoverColor,
    Color? pressColor,
    Color? disabledColor,
    Color? foregroundColor,
    BorderRadius? borderRadius,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    TextStyle? textStyle,
  }) {
    return ButtonCustomization(
      width: width,
      height: height,
      decoration: (status) {
        Color? color = backgroundColor;
        if (status.enabled < 0.5) {
          color = disabledColor ?? const Color(0xFFE0E0E0);
        } else if (status.hovered > 0.0) {
          // Simple interpolation logic could go here, but for 'simple' we just switch
          color = hoverColor ?? backgroundColor?.withValues(alpha: 0.8);
        }
        // Active state could be checked here if exposed in status, or inferred.

        return BoxDecoration(
          color: color,
          borderRadius: borderRadius ?? BorderRadius.circular(4),
        );
      },
      textStyle: (status) {
        return (textStyle ?? const TextStyle()).copyWith(
          color: foregroundColor,
        );
      },
    );
  }
}

/// Customization specific to TextFields.
class TextFieldCustomization extends ControlCustomization<ControlStatus> {
  const TextFieldCustomization({
    required super.decoration,
    required super.textStyle,
    this.cursorColor,
  });

  final Color? cursorColor;

  /// A simple factory for creating a [TextFieldCustomization].
  factory TextFieldCustomization.simple({
    Color? backgroundColor,
    Color? focusedColor,
    Color? borderColor,
    Color? focusedBorderColor,
    Color? cursorColor,
    Color? textColor,
    BorderRadius? borderRadius,
    TextStyle? textStyle,
    EdgeInsetsGeometry? padding,
  }) {
    return TextFieldCustomization(
      cursorColor: cursorColor,
      decoration: (status) {
        final isFocused = status.focused > 0.0;
        final color = isFocused
            ? (focusedColor ?? backgroundColor)
            : backgroundColor;
        final border = isFocused
            ? Border.all(
                color: focusedBorderColor ?? const Color(0xFF2196F3),
                width: 2,
              )
            : Border.all(color: borderColor ?? const Color(0xFF9E9E9E));

        return BoxDecoration(
          color: color,
          border: border,
          borderRadius: borderRadius ?? BorderRadius.circular(4),
        );
      },
      textStyle: (status) =>
          (textStyle ?? const TextStyle()).copyWith(color: textColor),
    );
  }
}

/// Customization for Checkboxes.
class CheckboxCustomization extends ControlCustomization<ToggleControlStatus> {
  const CheckboxCustomization({
    required super.decoration,
    required super.textStyle, // Often unused but kept for consistency or label
    this.size,
  });
  final double? size;

  /// A simple factory for creating a [CheckboxCustomization].
  factory CheckboxCustomization.simple({
    Color? activeColor,
    Color? checkColor,
    Color? disabledColor,
    Color? inactiveColor,
    double? size,
    BorderRadius? borderRadius,
  }) {
    return CheckboxCustomization(
      size: size,
      decoration: (status) {
        final checked = status.checked > 0.5;
        final enabled = status.enabled > 0.5;
        Color color = inactiveColor ?? const Color(0xFFFFFFFF);
        if (!enabled) {
          color = disabledColor ?? const Color(0xFFE0E0E0);
        } else if (checked) {
          color = activeColor ?? const Color(0xFF2196F3);
        }

        return BoxDecoration(
          color: color,
          borderRadius: borderRadius ?? BorderRadius.circular(4),
          border: !checked && enabled
              ? Border.all(color: const Color(0xFF757575))
              : null,
        );
      },
      textStyle: (status) => TextStyle(
        color: checkColor ?? const Color(0xFFFFFFFF),
        fontSize: (size ?? 18) * 0.8,
      ),
    );
  }
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

  /// A simple factory for creating a [SwitchCustomization].
  factory SwitchCustomization.simple({
    Color? activeColor,
    Color? activeTrackColor,
    Color? inactiveThumbColor,
    Color? inactiveTrackColor,
    double? width,
    double? height,
  }) {
    return SwitchCustomization(
      width: width,
      height: height,
      decoration: (status) {
        final checked = status.checked > 0.5;
        Color color = checked
            ? (activeTrackColor ?? const Color(0xFFBBDEFB))
            : (inactiveTrackColor ?? const Color(0xFFE0E0E0));
        return BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        );
      },
      textStyle: (status) {
        final checked = status.checked > 0.5;
        return TextStyle(
          color: checked
              ? (activeColor ?? const Color(0xFF2196F3))
              : (inactiveThumbColor ?? const Color(0xFFFFFFFF)),
        );
      },
    );
  }
}

/// Customization for Radio buttons.
class RadioCustomization extends ControlCustomization<RadioControlStatus> {
  const RadioCustomization({
    required super.decoration,
    required super.textStyle,
    this.size,
  });
  final double? size;

  /// A simple factory for creating a [RadioCustomization].
  factory RadioCustomization.simple({
    Color? activeColor,
    Color? inactiveColor,
    Color? disabledColor,
    double? size,
  }) {
    return RadioCustomization(
      size: size,
      decoration: (status) {
        final selected = status.selected > 0.5;
        final enabled = status.enabled > 0.5;
        Color color = inactiveColor ?? const Color(0xFF757575);
        if (!enabled) {
          color = disabledColor ?? const Color(0xFFE0E0E0);
        } else if (selected) {
          color = activeColor ?? const Color(0xFF2196F3);
        }

        return BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        );
      },
      textStyle: (status) {
        final selected = status.selected > 0.5;
        final enabled = status.enabled > 0.5;
        Color color = inactiveColor ?? const Color(0xFF757575);
        if (!enabled) {
          color = disabledColor ?? const Color(0xFFE0E0E0);
        } else if (selected) {
          color = activeColor ?? const Color(0xFF2196F3);
        }
        return TextStyle(color: color);
      },
    );
  }
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

/// Customization for Date Cells in a DatePicker.
class DateCellCustomization
    extends ControlCustomization<DateCellControlStatus> {
  const DateCellCustomization({
    required super.decoration,
    required super.textStyle,
    this.padding,
    this.alignment,
  });

  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? alignment;
}

/// Customization for DatePickers.
class DatePickerCustomization
    extends ControlCustomization<DatePickerControlStatus> {
  const DatePickerCustomization({
    required super.decoration,
    required super.textStyle,
    required this.dayCustomization,
    this.headerTextStyle,
    this.weekdayTextStyle,
    this.cellPadding, // Outer padding for cells
    this.headerPadding,
    this.columnSpacing,
    this.rowSpacing,
  });

  /// Customization for the Day cells.
  final DateCellCustomization dayCustomization;

  /// Text style for the header (e.g. Month Year).
  final TextStyle? headerTextStyle;

  /// Text style for weekdays (Mon, Tue...).
  final TextStyle? weekdayTextStyle;

  final EdgeInsetsGeometry? cellPadding;
  final EdgeInsetsGeometry? headerPadding;
  final double? columnSpacing;
  final double? rowSpacing;
}

/// Customization for Color Items in a ColorPicker.
class ColorItemCustomization
    extends ControlCustomization<ColorItemControlStatus> {
  const ColorItemCustomization({
    required super.decoration,
    required super.textStyle, // Usually unused
    this.size,
    this.margin,
  });

  final Size? size;
  final EdgeInsetsGeometry? margin;

  factory ColorItemCustomization.simple({
    Size? size,
    EdgeInsetsGeometry? margin,
    Color? borderColor,
    Color? selectedBorderColor,
    double? borderWidth,
  }) {
    return ColorItemCustomization(
      size: size ?? const Size(32, 32),
      margin: margin ?? const EdgeInsets.all(4),
      decoration: (status) {
        final selected = status.selected > 0.5;
        // Note: The widget adds the 'color'. Here we just provide shape/border.
        return BoxDecoration(
          shape: BoxShape.circle,
          border: selected
              ? Border.all(
                  color: selectedBorderColor ?? const Color(0xFF000000),
                  width: borderWidth ?? 2,
                )
              : (borderColor != null
                    ? Border.all(color: borderColor, width: borderWidth ?? 1)
                    : null),
        );
      },
      textStyle: (_) => const TextStyle(),
    );
  }
}

/// Customization for ColorPickers.
class ColorPickerCustomization
    extends ControlCustomization<ColorPickerControlStatus> {
  const ColorPickerCustomization({
    required super.decoration,
    required super.textStyle,
    required this.itemCustomization,
    this.columns,
    this.spacing,
    this.runSpacing,
    this.padding,
  });

  final ColorItemCustomization itemCustomization;
  final int? columns;
  final double? spacing;
  final double? runSpacing;
  final EdgeInsetsGeometry? padding;

  factory ColorPickerCustomization.simple({
    ColorItemCustomization? itemCustomization,
    double? spacing,
    double? runSpacing,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
    BorderRadius? borderRadius,
  }) {
    return ColorPickerCustomization(
      itemCustomization: itemCustomization ?? ColorItemCustomization.simple(),
      spacing: spacing,
      runSpacing: runSpacing,
      padding: padding ?? const EdgeInsets.all(8),
      decoration: (status) {
        return BoxDecoration(
          color: backgroundColor, // Could be null (transparent)
          borderRadius: borderRadius,
        );
      },
      textStyle: (_) => const TextStyle(),
    );
  }
}

/// Customization for Tree Items.
class TreeItemCustomization
    extends ControlCustomization<TreeItemControlStatus> {
  const TreeItemCustomization({
    required super.decoration,
    required super.textStyle,
    this.indent,
    this.padding,
  });

  final double? indent; // Indentation per level
  final EdgeInsetsGeometry? padding;

  factory TreeItemCustomization.simple({
    double? indent,
    EdgeInsetsGeometry? padding,
    Color? selectedColor,
    Color? hoverColor,
    Color? textColor,
  }) {
    return TreeItemCustomization(
      indent: indent ?? 20.0,
      padding:
          padding ?? const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: (status) {
        final selected = status.selected > 0.5;
        final hovered = status.hovered > 0.5;
        Color color = const Color(0x00000000);
        if (selected) {
          color = selectedColor ?? const Color(0xFFE3F2FD);
        } else if (hovered) {
          color = hoverColor ?? const Color(0xFFF5F5F5);
        }

        return BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        );
      },
      textStyle: (status) =>
          TextStyle(color: textColor ?? const Color(0xFF000000)),
    );
  }
}

/// Customization for TreeView.
class TreeViewCustomization extends ControlCustomization<TreeControlStatus> {
  const TreeViewCustomization({
    required super.decoration,
    required super.textStyle,
    required this.itemCustomization,
  });

  final TreeItemCustomization itemCustomization;

  factory TreeViewCustomization.simple({
    TreeItemCustomization? itemCustomization,
  }) {
    return TreeViewCustomization(
      itemCustomization: itemCustomization ?? TreeItemCustomization.simple(),
      decoration: (_) => const BoxDecoration(),
      textStyle: (_) => const TextStyle(),
    );
  }
}

/// Customization for DataTable Rows.
class DataRowCustomization extends ControlCustomization<DataRowControlStatus> {
  const DataRowCustomization({
    required super.decoration,
    required super.textStyle,
  });

  factory DataRowCustomization.simple({
    Color? hoverColor,
    Color? selectedColor,
    TextStyle? textStyle,
  }) {
    return DataRowCustomization(
      decoration: (status) {
        if (status.selected > 0.5) {
          return BoxDecoration(color: selectedColor ?? const Color(0xFFE3F2FD));
        }
        if (status.hovered > 0.5) {
          return BoxDecoration(color: hoverColor ?? const Color(0xFFF5F5F5));
        }
        return const BoxDecoration(color: Color(0x00000000));
      },
      textStyle: (_) => textStyle ?? const TextStyle(),
    );
  }
}

/// Customization for DataTable.
class DataTableCustomization extends ControlCustomization<ControlStatus> {
  const DataTableCustomization({
    required super.decoration,
    required super.textStyle,
    required this.rowCustomization,
    this.headerTextStyle,
    this.headerDecoration,
    this.padding,
    this.dividerColor,
  });

  final DataRowCustomization rowCustomization;
  final TextStyle? headerTextStyle;
  final BoxDecoration? headerDecoration;
  final EdgeInsetsGeometry? padding;
  final Color? dividerColor;

  factory DataTableCustomization.simple({
    DataRowCustomization? rowCustomization,
    BoxDecoration? headerDecoration,
    TextStyle? headerTextStyle,
    EdgeInsetsGeometry? padding,
    Color? dividerColor,
  }) {
    return DataTableCustomization(
      rowCustomization: rowCustomization ?? DataRowCustomization.simple(),
      headerDecoration:
          headerDecoration ?? const BoxDecoration(color: Color(0xFFEEEEEE)),
      headerTextStyle:
          headerTextStyle ?? const TextStyle(fontWeight: FontWeight.bold),
      padding: padding,
      dividerColor: dividerColor ?? const Color(0xFFE0E0E0),
      decoration: (_) => const BoxDecoration(), // Usually container decoration
      textStyle: (_) => const TextStyle(),
    );
  }
}

/// Customization for Stepper.
class StepperCustomization extends ControlCustomization<StepControlStatus> {
  const StepperCustomization({
    required super.decoration, // Decoration for the step circle/indicator
    required super.textStyle,
    this.connectorColor,
    this.completedColor,
    this.activeColor,
    this.inactiveColor,
    this.padding,
  });

  final Color? connectorColor;
  final Color? completedColor;
  final Color? activeColor;
  final Color? inactiveColor;
  final EdgeInsetsGeometry? padding;

  factory StepperCustomization.simple({
    Color? activeColor,
    Color? completedColor,
    Color? inactiveColor,
    Color? connectorColor,
    EdgeInsetsGeometry? padding,
  }) {
    return StepperCustomization(
      activeColor: activeColor,
      completedColor: completedColor,
      inactiveColor: inactiveColor,
      connectorColor: connectorColor ?? const Color(0xFFE0E0E0),
      padding: padding,
      decoration: (status) {
        // This is for the numeric indicator circle usually
        final active = status.active > 0.5;
        final completed = status.completed > 0.5;
        Color c = inactiveColor ?? const Color(0xFFE0E0E0);
        if (completed) {
          c = completedColor ?? const Color(0xFF4CAF50);
        } else if (active) {
          c = activeColor ?? const Color(0xFF2196F3);
        }

        return BoxDecoration(color: c, shape: BoxShape.circle);
      },
      textStyle: (status) {
        return const TextStyle(color: Color(0xFFFFFFFF));
      },
    );
  }
}

/// Customization for Accordion.
class AccordionCustomization
    extends ControlCustomization<AccordionControlStatus> {
  const AccordionCustomization({
    required super.decoration,
    required super.textStyle,
    this.contentDecoration,
    this.contentPadding,
    this.headerPadding,
  });

  final Decoration? contentDecoration;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? headerPadding;

  factory AccordionCustomization.simple({
    Color? expandedColor,
    Color? collapsedColor,
    Color? contentBackgroundColor,
    EdgeInsetsGeometry? headerPadding,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return AccordionCustomization(
      headerPadding: headerPadding ?? const EdgeInsets.all(16),
      contentPadding: contentPadding ?? const EdgeInsets.all(16),
      contentDecoration: BoxDecoration(
        color: contentBackgroundColor ?? const Color(0xFFFAFAFA),
        border: const Border(top: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      decoration: (status) {
        // Header decoration
        final expanded = status.expanded > 0.5;
        return BoxDecoration(
          color: expanded
              ? (expandedColor ?? const Color(0xFFE3F2FD))
              : (collapsedColor ?? const Color(0xFFFFFFFF)),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        );
      },
      textStyle: (_) => const TextStyle(fontWeight: FontWeight.bold),
    );
  }
}
