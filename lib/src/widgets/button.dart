import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import '../foundation/status.dart';
import '../theme/theme.dart';

/// Status for a Button.
class ButtonStatus extends MutableControlStatus {}

/// A button that follows the BlankCanvas architecture.
class Button extends StatefulWidget {
  const Button({
    super.key,
    required this.onPressed,
    required this.child,
    this.tag,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final String? tag;

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> with TickerProviderStateMixin {
  final ButtonStatus _status = ButtonStatus();

  late final AnimationController _hoverController;
  late final AnimationController _focusController;

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

    _focusNode.addListener(() {
      _focusNode.hasFocus
          ? _focusController.forward()
          : _focusController.reverse();
    });

    _status.enabled = widget.onPressed != null ? 1.0 : 0.0;
  }

  @override
  void didUpdateWidget(Button oldWidget) {
    super.didUpdateWidget(oldWidget);
    _status.enabled = widget.onPressed != null ? 1.0 : 0.0;
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _focusController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization = customizations.getButton(widget.tag);

    if (customization == null) {
      return widget.child;
    }

    final decoration = customization.decoration(_status);
    final textStyle = customization.textStyle(_status);

    return MouseRegion(
      onEnter: (_) => _hoverController.forward(),
      onExit: (_) => _hoverController.reverse(),
      cursor: widget.onPressed != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Focus(
          focusNode: _focusNode,
          child: _ButtonRenderWidget(
            decoration: decoration is BoxDecoration
                ? decoration
                : const BoxDecoration(),
            width: customization.width,
            height: customization.height,
            child: DefaultTextStyle(
              style: textStyle,
              child: Center(child: widget.child),
            ),
          ),
        ),
      ),
    );
  }
}

class _ButtonRenderWidget extends SingleChildRenderObjectWidget {
  const _ButtonRenderWidget({
    super.child,
    required this.decoration,
    this.width,
    this.height,
  });

  final BoxDecoration decoration;
  final double? width;
  final double? height;

  @override
  RenderButton createRenderObject(BuildContext context) {
    return RenderButton(decoration: decoration, width: width, height: height);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderButton renderObject,
  ) {
    renderObject
      ..decoration = decoration
      ..width = width
      ..height = height;
  }
}

class RenderButton extends RenderProxyBox {
  RenderButton({
    required BoxDecoration decoration,
    double? width,
    double? height,
  }) : _decoration = decoration,
       _width = width,
       _height = height;

  BoxDecoration _decoration;
  BoxDecoration get decoration => _decoration;
  set decoration(BoxDecoration value) {
    if (_decoration == value) return;
    _decoration = value;
    markNeedsPaint();
  }

  double? _width;
  double? get width => _width;
  set width(double? value) {
    if (_width == value) return;
    _width = value;
    markNeedsLayout();
  }

  double? _height;
  double? get height => _height;
  set height(double? value) {
    if (_height == value) return;
    _height = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    if (child != null) {
      final double? constrainedWidth = width;
      final double? constrainedHeight = height;

      if (constrainedWidth != null && constrainedHeight != null) {
        child!.layout(
          BoxConstraints.tight(Size(constrainedWidth, constrainedHeight)),
          parentUsesSize: true,
        );
        size = child!.size;
      } else {
        child!.layout(constraints, parentUsesSize: true);
        size = constraints.constrain(
          Size(
            constrainedWidth ?? child!.size.width,
            constrainedHeight ?? child!.size.height,
          ),
        );
      }
    } else {
      size = constraints.constrain(Size(width ?? 0.0, height ?? 0.0));
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Rect rect = offset & size;
    final Paint paint = Paint()
      ..color = decoration.color ?? const Color(0x00000000);

    // Paint shadow
    if (decoration.boxShadow != null) {
      for (final shadow in decoration.boxShadow!) {
        context.canvas.drawRect(
          rect.shift(shadow.offset).inflate(shadow.spreadRadius),
          shadow.toPaint(),
        );
      }
    }

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

    if (child != null) {
      context.paintChild(child!, offset);
    }
  }
}
