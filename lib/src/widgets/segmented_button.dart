import 'package:flutter/widgets.dart';
import '../foundation/status.dart';
import '../theme/customization.dart';

/// Customization for SegmentedButton.
class SegmentedButtonCustomization extends ControlCustomization<ControlStatus> {
  const SegmentedButtonCustomization({
    required super.decoration,
    required super.textStyle,
    this.selectedDecoration,
    this.selectedTextStyle,
    this.padding,
    this.borderRadius,
  });

  final BoxDecoration Function(ControlStatus)? selectedDecoration;
  final TextStyle Function(ControlStatus)? selectedTextStyle;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  factory SegmentedButtonCustomization.simple({
    Color? backgroundColor,
    Color? selectedColor,
    Color? textColor,
    Color? selectedTextColor,
    Color? borderColor,
    EdgeInsets? padding,
    BorderRadius? borderRadius,
  }) {
    return SegmentedButtonCustomization(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      decoration: (status) => BoxDecoration(
        color: backgroundColor ?? const Color(0xFFFFFFFF),
        border: Border.all(color: borderColor ?? const Color(0xFFBDBDBD)),
      ),
      selectedDecoration: (status) =>
          BoxDecoration(color: selectedColor ?? const Color(0xFF2196F3)),
      textStyle: (status) =>
          TextStyle(color: textColor ?? const Color(0xFF424242), fontSize: 14),
      selectedTextStyle: (status) => TextStyle(
        color: selectedTextColor ?? const Color(0xFFFFFFFF),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

/// A segment in a SegmentedButton.
class Segment<T> {
  const Segment({required this.value, required this.label, this.icon});

  final T value;
  final Widget label;
  final Widget? icon;
}

/// A horizontal set of toggle buttons with mutually exclusive selection.
class SegmentedButton<T> extends StatefulWidget {
  const SegmentedButton({
    super.key,
    required this.segments,
    required this.selected,
    required this.onSelectionChanged,
    this.multiSelectionEnabled = false,
    this.tag,
  });

  final List<Segment<T>> segments;
  final Set<T> selected;
  final ValueChanged<Set<T>> onSelectionChanged;
  final bool multiSelectionEnabled;
  final String? tag;

  @override
  State<SegmentedButton<T>> createState() => _SegmentedButtonState<T>();
}

class _SegmentedButtonState<T> extends State<SegmentedButton<T>> {
  void _handleSegmentTap(T value) {
    Set<T> newSelection;
    if (widget.multiSelectionEnabled) {
      newSelection = Set<T>.from(widget.selected);
      if (newSelection.contains(value)) {
        newSelection.remove(value);
      } else {
        newSelection.add(value);
      }
    } else {
      newSelection = {value};
    }
    widget.onSelectionChanged(newSelection);
  }

  @override
  Widget build(BuildContext context) {
    final customization = SegmentedButtonCustomization.simple();
    final borderRadius = customization.borderRadius ?? BorderRadius.circular(8);

    return ClipRRect(
      borderRadius: borderRadius,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFBDBDBD)),
          borderRadius: borderRadius,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: widget.segments.asMap().entries.map((entry) {
            final index = entry.key;
            final segment = entry.value;
            final isSelected = widget.selected.contains(segment.value);
            final isFirst = index == 0;
            final isLast = index == widget.segments.length - 1;

            return _SegmentButton<T>(
              segment: segment,
              isSelected: isSelected,
              isFirst: isFirst,
              isLast: isLast,
              customization: customization,
              onTap: () => _handleSegmentTap(segment.value),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _SegmentButton<T> extends StatefulWidget {
  const _SegmentButton({
    required this.segment,
    required this.isSelected,
    required this.isFirst,
    required this.isLast,
    required this.customization,
    required this.onTap,
  });

  final Segment<T> segment;
  final bool isSelected;
  final bool isFirst;
  final bool isLast;
  final SegmentedButtonCustomization customization;
  final VoidCallback onTap;

  @override
  State<_SegmentButton<T>> createState() => _SegmentButtonState<T>();
}

class _SegmentButtonState<T> extends State<_SegmentButton<T>>
    with SingleTickerProviderStateMixin {
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
    _status.selected = widget.isSelected ? 1.0 : 0.0;
  }

  @override
  void didUpdateWidget(_SegmentButton<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      _status.selected = widget.isSelected ? 1.0 : 0.0;
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final decoration = widget.isSelected
        ? widget.customization.selectedDecoration?.call(_status)
        : widget.customization.decoration(_status);
    final textStyle = widget.isSelected
        ? widget.customization.selectedTextStyle?.call(_status)
        : widget.customization.textStyle(_status);
    final padding =
        widget.customization.padding ??
        const EdgeInsets.symmetric(horizontal: 16, vertical: 10);

    return Semantics(
      selected: widget.isSelected,
      inMutuallyExclusiveGroup: true,
      button: true,
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => _hoverController.forward(),
        onExit: (_) => _hoverController.reverse(),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: DecoratedBox(
            decoration: decoration ?? const BoxDecoration(),
            child: Padding(
              padding: padding,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.segment.icon != null) ...[
                    widget.segment.icon!,
                    const SizedBox(width: 8),
                  ],
                  DefaultTextStyle(
                    style: textStyle ?? const TextStyle(),
                    child: widget.segment.label,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
