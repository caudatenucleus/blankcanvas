import 'package:flutter/widgets.dart';
import '../foundation/status.dart';
import '../theme/customization.dart';

/// Customization for Chip widget.
class ChipCustomization extends ControlCustomization<RadioControlStatus> {
  const ChipCustomization({
    required super.decoration,
    required super.textStyle,
    this.padding,
    this.deleteIconColor,
  });

  final EdgeInsets? padding;
  final Color? deleteIconColor;

  factory ChipCustomization.simple({
    Color? backgroundColor,
    Color? selectedColor,
    Color? textColor,
    Color? deleteIconColor,
    EdgeInsets? padding,
    BorderRadius? borderRadius,
  }) {
    return ChipCustomization(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      deleteIconColor: deleteIconColor ?? const Color(0xFF757575),
      decoration: (status) => BoxDecoration(
        color: status.selected > 0.5
            ? (selectedColor ?? const Color(0xFF2196F3))
            : (backgroundColor ?? const Color(0xFFE0E0E0)),
        borderRadius: borderRadius ?? BorderRadius.circular(16),
      ),
      textStyle: (status) => TextStyle(
        color: status.selected > 0.5
            ? const Color(0xFFFFFFFF)
            : (textColor ?? const Color(0xFF424242)),
        fontSize: 14,
      ),
    );
  }
}

/// A compact element representing an attribute, text, or action.
class Chip extends StatefulWidget {
  const Chip({
    super.key,
    required this.label,
    this.selected = false,
    this.onSelected,
    this.onDeleted,
    this.avatar,
    this.tag,
  });

  final Widget label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final VoidCallback? onDeleted;
  final Widget? avatar;
  final String? tag;

  @override
  State<Chip> createState() => _ChipState();
}

class _ChipState extends State<Chip> with SingleTickerProviderStateMixin {
  final RadioControlStatus _status = RadioControlStatus();
  late AnimationController _hoverController;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _hoverController.addListener(() {
      setState(() => _status.hovered = _hoverController.value);
    });
    _status.selected = widget.selected ? 1.0 : 0.0;
  }

  @override
  void didUpdateWidget(Chip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected) {
      _status.selected = widget.selected ? 1.0 : 0.0;
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.onSelected?.call(!widget.selected);
  }

  @override
  Widget build(BuildContext context) {
    final customization = ChipCustomization.simple();
    final decoration = customization.decoration(_status);
    final textStyle = customization.textStyle(_status);
    final padding =
        customization.padding ??
        const EdgeInsets.symmetric(horizontal: 12, vertical: 6);

    return Semantics(
      selected: widget.selected,
      button: true,
      onTap: _handleTap,
      child: MouseRegion(
        onEnter: (_) => _hoverController.forward(),
        onExit: (_) => _hoverController.reverse(),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: _handleTap,
          child: DecoratedBox(
            decoration: decoration is BoxDecoration
                ? decoration
                : const BoxDecoration(),
            child: Padding(
              padding: padding,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.avatar != null) ...[
                    widget.avatar!,
                    const SizedBox(width: 6),
                  ],
                  DefaultTextStyle(style: textStyle, child: widget.label),
                  if (widget.onDeleted != null) ...[
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onDeleted,
                      child: Icon(
                        const IconData(0x2715), // ✕
                        size: 16,
                        color: customization.deleteIconColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
