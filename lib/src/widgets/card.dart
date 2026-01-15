import 'package:flutter/widgets.dart';
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
      () => _status.hovered = _hoverController.value,
    );
    _focusController.addListener(
      () => _status.focused = _focusController.value,
    );

    // Cards usually don't have intrinsic focus logic unless they are interactive cards.
    // For now we assume they are just containers, but we support hover.
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

    if (customization == null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          border: Border.all(color: const Color(0xFFDDDDDD)),
        ),
        child: widget.child,
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
          child: Container(
            decoration: decoration,
            child: DefaultTextStyle(style: textStyle, child: widget.child),
          ),
        );
      },
    );
  }
}
