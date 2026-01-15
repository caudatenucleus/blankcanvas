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

    final decoration = customization.decoration(_status);
    final double width = customization.width ?? 40.0;
    final double height = customization.height ?? 20.0;

    return Semantics(
      toggled: widget.value,
      enabled: widget.onChanged != null,
      onTap: _handleTap,
      child: MouseRegion(
        onEnter: (_) => _hoverController.forward(),
        onExit: (_) => _hoverController.reverse(),
        cursor: widget.onChanged != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: _handleTap,
          child: Focus(
            focusNode: _focusNode,
            child: _SwitchRenderWidget(
              decoration: decoration is BoxDecoration
                  ? decoration
                  : const BoxDecoration(),
              width: width,
              height: height,
            ),
          ),
        ),
      ),
    );
  }
}

class _SwitchRenderWidget extends LeafRenderObjectWidget {
  const _SwitchRenderWidget({
    required this.decoration,
    required this.width,
    required this.height,
  });

  final BoxDecoration decoration;
  final double width;
  final double height;

  @override
  RenderSwitch createRenderObject(BuildContext context) {
    return RenderSwitch(
      decoration: decoration,
      widthValue: width,
      heightValue: height,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderSwitch renderObject,
  ) {
    renderObject
      ..decoration = decoration
      ..widthValue = width
      ..heightValue = height;
  }
}

class RenderSwitch extends RenderBox {
  RenderSwitch({
    required BoxDecoration decoration,
    required double widthValue,
    required double heightValue,
  }) : _decoration = decoration,
       _widthValue = widthValue,
       _heightValue = heightValue;

  BoxDecoration _decoration;
  BoxDecoration get decoration => _decoration;
  set decoration(BoxDecoration value) {
    if (_decoration == value) return;
    _decoration = value;
    markNeedsPaint();
  }

  double _widthValue;
  double get widthValue => _widthValue;
  set widthValue(double value) {
    if (_widthValue == value) return;
    _widthValue = value;
    markNeedsLayout();
  }

  double _heightValue;
  double get heightValue => _heightValue;
  set heightValue(double value) {
    if (_heightValue == value) return;
    _heightValue = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    size = constraints.constrain(Size(widthValue, heightValue));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Rect rect = offset & size;
    final Paint paint = Paint()
      ..color = decoration.color ?? const Color(0xFFCCCCCC);

    // Paint background (track)
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

    // Thumb drawing would happen here if it wasn't part of the decoration.
    // In our Status system, the decoration usually changes its appearance (e.g. gradient)
    // based on 'checked' double. If we want a separate physical thumb in the render object,
    // we'd need more data from the customization.
  }
}
