import 'package:flutter/widgets.dart';
import '../foundation/status.dart';
import '../theme/theme.dart';

/// Status for a Switch.
class SwitchStatus extends ToggleControlStatus {}

class Switch extends StatefulWidget {
  const Switch({
    super.key,
    required this.value,
    required this.onChanged,
    this.tag,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? tag;

  @override
  State<Switch> createState() => _SwitchState();
}

class _SwitchState extends State<Switch> with TickerProviderStateMixin {
  final SwitchStatus _status = SwitchStatus();

  late final AnimationController _hoverController;
  late final AnimationController _focusController;
  late final AnimationController _checkController;

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _focusController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _hoverController.addListener(
      () => _status.hovered = _hoverController.value,
    );
    _focusController.addListener(
      () => _status.focused = _focusController.value,
    );
    _checkController.addListener(
      () => _status.checked = _checkController.value,
    );

    _focusNode.addListener(() {
      _focusNode.hasFocus
          ? _focusController.forward()
          : _focusController.reverse();
    });

    _status.enabled = widget.onChanged != null ? 1.0 : 0.0;
    if (widget.value) {
      _checkController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(Switch oldWidget) {
    super.didUpdateWidget(oldWidget);
    _status.enabled = widget.onChanged != null ? 1.0 : 0.0;
    if (widget.value != oldWidget.value) {
      widget.value ? _checkController.forward() : _checkController.reverse();
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _focusController.dispose();
    _checkController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onChanged != null) {
      widget.onChanged!(!widget.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization = customizations.getSwitch(widget.tag);

    if (customization == null) {
      return SizedBox(
        width: 40,
        height: 20,
        child: ColoredBox(
          color: widget.value
              ? const Color(0xFF000000)
              : const Color(0xFFCCCCCC),
        ),
      );
    }

    return ListenableBuilder(
      listenable: _status,
      builder: (context, _) {
        final decoration = customization.decoration(_status);

        return MouseRegion(
          onEnter: (_) => _hoverController.forward(),
          onExit: (_) => _hoverController.reverse(),
          cursor: widget.onChanged != null
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          child: GestureDetector(
            onTap: _handleTap,
            // TODO: Implement drag gestures as per Design Doc
            child: Focus(
              focusNode: _focusNode,
              child: Container(
                width: customization.width ?? 40.0,
                height: customization.height ?? 20.0,
                decoration: decoration,
              ),
            ),
          ),
        );
      },
    );
  }
}
