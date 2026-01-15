import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import '../foundation/status.dart';
import '../theme/theme.dart';

/// Status for a Card.
class CardStatus extends CardControlStatus {}

class Card extends StatefulWidget {
  const Card({super.key, required this.child, this.tag});

  final Widget child;
  final String? tag;

  @override
  State<Card> createState() => _CardState();
}

class _CardState extends State<Card> with TickerProviderStateMixin {
  final CardStatus _status = CardStatus();

  late final AnimationController _hoverController;
  late final AnimationController _focusController;

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
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _focusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization = customizations.getCard(widget.tag);

    final decoration =
        customization?.decoration(_status) ??
        BoxDecoration(
          color: const Color(0xFFFFFFFF),
          border: Border.all(color: const Color(0xFFDDDDDD)),
        );
    final textStyle = customization?.textStyle(_status) ?? const TextStyle();

    return MouseRegion(
      onEnter: (_) => _hoverController.forward(),
      onExit: (_) => _hoverController.reverse(),
      child: _CardRenderWidget(
        decoration: decoration is BoxDecoration
            ? decoration
            : const BoxDecoration(),
        child: DefaultTextStyle(style: textStyle, child: widget.child),
      ),
    );
  }
}

class _CardRenderWidget extends SingleChildRenderObjectWidget {
  const _CardRenderWidget({super.child, required this.decoration});
  final BoxDecoration decoration;

  @override
  RenderCard createRenderObject(BuildContext context) {
    return RenderCard(decoration: decoration);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderCard renderObject,
  ) {
    renderObject.decoration = decoration;
  }
}

class RenderCard extends RenderProxyBox {
  RenderCard({required BoxDecoration decoration}) : _decoration = decoration;

  BoxDecoration _decoration;
  BoxDecoration get decoration => _decoration;
  set decoration(BoxDecoration value) {
    if (_decoration == value) return;
    _decoration = value;
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // Paint background
    final Paint paint = Paint()
      ..color = decoration.color ?? const Color(0xFFFFFFFF);
    final Rect rect = offset & size;

    if (decoration.boxShadow != null) {
      for (final shadow in decoration.boxShadow!) {
        context.canvas.drawRect(
          rect.shift(shadow.offset).inflate(shadow.spreadRadius),
          shadow.toPaint(),
        );
      }
    }

    if (decoration.borderRadius != null) {
      final borderRadius = decoration.borderRadius!.resolve(TextDirection.ltr);
      final rrect = borderRadius.toRRect(rect);
      context.canvas.drawRRect(rrect, paint);

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
