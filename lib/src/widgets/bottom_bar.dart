import 'package:flutter/widgets.dart';
import '../foundation/status.dart';
import '../theme/theme.dart';

/// Status for a BottomBar Item.
class BottomBarItemStatus extends BottomBarItemControlStatus {}

/// A Bottom Navigation Bar Item.
class BottomBarItem extends StatefulWidget {
  const BottomBarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.tag,
  });

  final Widget icon;
  final Widget label;
  final bool selected;
  final VoidCallback onTap;
  final String? tag;

  @override
  State<BottomBarItem> createState() => _BottomBarItemState();
}

class _BottomBarItemState extends State<BottomBarItem>
    with SingleTickerProviderStateMixin {
  final BottomBarItemStatus _status = BottomBarItemStatus();
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
    _status.selected = widget.selected ? 1.0 : 0.0;
  }

  @override
  void didUpdateWidget(BottomBarItem oldWidget) {
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

  @override
  Widget build(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization = customizations.getBottomBarItem(widget.tag);

    if (customization == null) {
      // Fallback
      return GestureDetector(
        onTap: widget.onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.icon,
            DefaultTextStyle(
              style: TextStyle(
                fontWeight: widget.selected
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
              child: widget.label,
            ),
          ],
        ),
      );
    }

    return ListenableBuilder(
      listenable: _status,
      builder: (context, _) {
        final decoration = customization.decoration(_status);
        final textStyle = customization.textStyle(_status);

        return MouseRegion(
          onEnter: (_) => _hoverController.forward(),
          onExit: (_) => _hoverController.reverse(),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              decoration: decoration,
              padding: customization.padding ?? const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // We might want to theme the icon too, closely coupled to text style usually
                  IconTheme(
                    data: IconThemeData(
                      color: textStyle.color,
                      size: textStyle.fontSize != null
                          ? textStyle.fontSize! * 1.5
                          : 24,
                    ),
                    child: widget.icon,
                  ),
                  DefaultTextStyle(style: textStyle, child: widget.label),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A Bottom Navigation Bar.
class BottomBar extends StatelessWidget {
  const BottomBar({super.key, required this.items, this.tag});

  final List<Widget> items;
  final String? tag;

  @override
  Widget build(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization = customizations.getBottomBar(tag);

    if (customization == null) {
      return Container(
        color: const Color(0xFFEEEEEE),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items,
        ),
      );
    }

    final status = BottomBarControlStatus(); // Static

    final decoration = customization.decoration(status);
    // final textStyle = customization.textStyle(status); // Usually unused for container, but maybe...

    return Container(
      decoration: decoration,
      height: customization.height,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items,
      ),
    );
  }
}
