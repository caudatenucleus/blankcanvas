import 'package:flutter/widgets.dart';
import '../foundation/status.dart';
import '../theme/theme.dart';
import '../theme/customization.dart';

/// Status for a single Tab.
class TabStatus extends TabControlStatus {}

/// A Segmented Control / Tab Bar.
/// It renders a list of items and handles selection.
/// Each item is a 'Tab'.
class TabControl<T> extends StatefulWidget {
  const TabControl({
    super.key,
    required this.items,
    required this.groupValue,
    required this.onChanged,
    this.itemBuilder,
    this.tag,
  });

  final List<T> items;
  final T groupValue;
  final ValueChanged<T> onChanged;
  final Widget Function(BuildContext context, T item, TabStatus status)?
  itemBuilder;
  final String? tag;

  @override
  State<TabControl<T>> createState() => _TabControlState();
}

class _TabControlState<T> extends State<TabControl<T>> {
  // We need a status for EACH item?
  // No, usually each item has its own status (hovered, selected).
  // So we probably need a widget for each item.

  @override
  Widget build(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization = customizations.getTab(widget.tag);

    // If no customization, render raw row
    if (customization == null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: widget.items.map((item) {
          final isSelected = item == widget.groupValue;
          return GestureDetector(
            onTap: () => widget.onChanged(item),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "$item",
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: widget.items.map((item) {
        return _TabItem<T>(
          item: item,
          isSelected: item == widget.groupValue,
          onChanged: widget.onChanged,
          customization: customization,
          builder: widget.itemBuilder,
        );
      }).toList(),
    );
  }
}

class _TabItem<T> extends StatefulWidget {
  const _TabItem({
    required this.item,
    required this.isSelected,
    required this.onChanged,
    required this.customization,
    this.builder,
  });

  final T item;
  final bool isSelected;
  final ValueChanged<T> onChanged;
  final TabCustomization customization;
  final Widget Function(BuildContext context, T item, TabStatus status)?
  builder;

  @override
  State<_TabItem<T>> createState() => _TabItemState<T>();
}

class _TabItemState<T> extends State<_TabItem<T>>
    with SingleTickerProviderStateMixin {
  final TabStatus _status = TabStatus();
  late final AnimationController _hoverController;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _hoverController.addListener(
      () => _status.hovered = _hoverController.value,
    );
    _status.selected = widget.isSelected ? 1.0 : 0.0;
  }

  @override
  void didUpdateWidget(_TabItem<T> oldWidget) {
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
    return ListenableBuilder(
      listenable: _status,
      builder: (context, _) {
        final decoration = widget.customization.decoration(_status);
        final textStyle = widget.customization.textStyle(_status);

        Widget child;
        if (widget.builder != null) {
          child = widget.builder!(context, widget.item, _status);
        } else {
          child = Text("${widget.item}");
        }

        return MouseRegion(
          onEnter: (_) => _hoverController.forward(),
          onExit: (_) => _hoverController.reverse(),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => widget.onChanged(widget.item),
            child: Container(
              decoration: decoration,
              padding:
                  widget.customization.padding ??
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: DefaultTextStyle(style: textStyle, child: child),
            ),
          ),
        );
      },
    );
  }
}
