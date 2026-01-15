import 'package:flutter/widgets.dart';
import '../foundation/status.dart';
import '../theme/theme.dart';

/// Status for a Radio button.
class RadioStatus extends RadioControlStatus {}

class Radio<T> extends StatefulWidget {
  const Radio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.tag,
  });

  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final String? tag;

  @override
  State<Radio<T>> createState() => _RadioState<T>();
}

class _RadioState<T> extends State<Radio<T>> with TickerProviderStateMixin {
  final RadioStatus _status = RadioStatus();

  late final AnimationController _hoverController;
  late final AnimationController _focusController;
  late final AnimationController _selectController;

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
    _selectController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _hoverController.addListener(
      () => _status.hovered = _hoverController.value,
    );
    _focusController.addListener(
      () => _status.focused = _focusController.value,
    );
    _selectController.addListener(
      () => _status.selected = _selectController.value,
    );

    _focusNode.addListener(() {
      _focusNode.hasFocus
          ? _focusController.forward()
          : _focusController.reverse();
    });

    _status.enabled = widget.onChanged != null ? 1.0 : 0.0;
    if (widget.value == widget.groupValue) {
      _selectController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(Radio<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _status.enabled = widget.onChanged != null ? 1.0 : 0.0;
    if (widget.value == widget.groupValue) {
      _selectController.forward();
    } else {
      _selectController.reverse();
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _focusController.dispose();
    _selectController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onChanged != null) {
      widget.onChanged!(widget.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization = customizations.getRadio(widget.tag);

    if (customization == null) {
      return SizedBox(
        width: 18,
        height: 18,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.value == widget.groupValue
                ? const Color(0xFF000000)
                : const Color(0xFFCCCCCC),
          ),
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
            child: Focus(
              focusNode: _focusNode,
              child: Container(
                width: customization.size ?? 18.0,
                height: customization.size ?? 18.0,
                decoration: decoration,
              ),
            ),
          ),
        );
      },
    );
  }
}
