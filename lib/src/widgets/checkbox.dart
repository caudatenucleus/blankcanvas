import 'package:flutter/widgets.dart';

import '../foundation/status.dart';
import '../theme/theme.dart';

/// Status for a Checkbox.
class CheckboxStatus extends ToggleControlStatus {}

class Checkbox extends StatefulWidget {
  const Checkbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.tag,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? tag;

  @override
  State<Checkbox> createState() => _CheckboxState();
}

class _CheckboxState extends State<Checkbox> with TickerProviderStateMixin {
  final CheckboxStatus _status = CheckboxStatus();

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
      () => setState(() {
        _status.hovered = _hoverController.value;
      }),
    );
    _focusController.addListener(
      () => setState(() {
        _status.focused = _focusController.value;
      }),
    );
    _checkController.addListener(
      () => setState(() {
        _status.checked = _checkController.value;
      }),
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
  void didUpdateWidget(Checkbox oldWidget) {
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
    final customization = customizations.getCheckbox(widget.tag);

    if (customization == null) {
      return SizedBox(
        width: 18,
        height: 18,
        child: ColoredBox(
          color: widget.value
              ? const Color(0xFF000000)
              : const Color(0xFFCCCCCC),
        ),
      );
    }

    final decoration = customization.decoration(_status);
    final double size = customization.size ?? 18.0;

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
          child: _CheckboxRenderWidget(
            decoration: decoration is BoxDecoration
                ? decoration
                : const BoxDecoration(),
            size: size,
          ),
        ),
      ),
    );
  }
}

class _CheckboxRenderWidget extends LeafRenderObjectWidget {
  const _CheckboxRenderWidget({required this.decoration, required this.size});

  final BoxDecoration decoration;
  final double size;

  @override
  RenderCheckbox createRenderObject(BuildContext context) {
    return RenderCheckbox(decoration: decoration, sizeValue: size);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderCheckbox renderObject,
  ) {
    renderObject
      ..decoration = decoration
      ..sizeValue = size;
  }
}

class RenderCheckbox extends RenderBox {
  RenderCheckbox({required BoxDecoration decoration, required double sizeValue})
    : _decoration = decoration,
      _sizeValue = sizeValue;

  BoxDecoration _decoration;
  BoxDecoration get decoration => _decoration;
  set decoration(BoxDecoration value) {
    if (_decoration == value) return;
    _decoration = value;
    markNeedsPaint();
  }

  double _sizeValue;
  double get sizeValue => _sizeValue;
  set sizeValue(double value) {
    if (_sizeValue == value) return;
    _sizeValue = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    size = constraints.constrain(Size.square(sizeValue));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Rect rect = offset & size;
    final Paint paint = Paint()
      ..color = decoration.color ?? const Color(0xFFCCCCCC);

    // Paint background
    if (decoration.borderRadius != null) {
      final borderRadius = decoration.borderRadius!.resolve(TextDirection.ltr);
      context.canvas.drawRRect(borderRadius.toRRect(rect), paint);
      if (decoration.border != null) {
        decoration.border!.paint(
          context.canvas,
          rect,
          borderRadius: borderRadius,
        );
      }
    } else {
      context.canvas.drawRect(rect, paint);
      if (decoration.border != null) {
        decoration.border!.paint(context.canvas, rect);
      }
    }

    // Note: The actual "check" mark is often part of the decoration in our system,
    // or we could draw it here manually if we wanted a more standardized look.
    // For now we trust the decoration provided by the theme.
  }
}
