import 'package:flutter/widgets.dart';
import '../foundation/status.dart';
import '../theme/theme.dart';

/// Status for a Dialog.
class DialogStatus extends CardControlStatus {}

/// A Dialog container.
class Dialog extends StatefulWidget {
  const Dialog({super.key, required this.child, this.tag});

  final Widget child;
  final String? tag;

  @override
  State<Dialog> createState() => _DialogState();
}

class _DialogState extends State<Dialog> {
  final DialogStatus _status = DialogStatus();

  // Dialogs typically don't have hover/focus interaction in the same way, but they could.
  // We'll keep it simple for now and just render the decoration.

  @override
  Widget build(BuildContext context) {
    // Note: When used in showDialog, the context must be one that contains the CustomizedTheme.
    // Standard showDialog/showGeneralDialog puts the route above the Navigator.
    // So CustomizedTheme must be above Navigator (e.g. wrapping MaterialApp/WidgetsApp).

    final customizations = CustomizedTheme.of(context);
    final customization = customizations.getDialog(widget.tag);

    if (customization == null) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFFFFFFFF),
            boxShadow: [BoxShadow(blurRadius: 10, color: Color(0x40000000))],
          ),
          child: widget.child,
        ),
      );
    }

    return ListenableBuilder(
      listenable: _status,
      builder: (context, _) {
        final decoration = customization.decoration(_status);
        final textStyle = customization.textStyle(_status);

        return Center(
          child: Container(
            decoration: decoration,
            // Dialogs usually have padding defined by their content or customization?
            // Hixie's doc doesn't specify padding in customization, so we assume decoration handles it or child does.
            // Decoration usually doesn't handle padding (except sometimes).
            // We'll let the user handle padding in the child or decoration.
            child: DefaultTextStyle(style: textStyle, child: widget.child),
          ),
        );
      },
    );
  }
}
