import 'package:flutter/widgets.dart';
import '../foundation/status.dart';
import '../theme/theme.dart';

/// Status for a TextField.
class TextFieldStatus extends MutableControlStatus {}

class TextField extends StatefulWidget {
  const TextField({super.key, this.controller, this.tag, this.placeholder});

  final TextEditingController? controller;
  final String? tag;
  final String? placeholder;

  @override
  State<TextField> createState() => _TextFieldState();
}

class _TextFieldState extends State<TextField> with TickerProviderStateMixin {
  final TextFieldStatus _status = TextFieldStatus();
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  late final AnimationController _hoverController;
  late final AnimationController _focusController;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();

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

    _focusNode.addListener(() {
      _focusNode.hasFocus
          ? _focusController.forward()
          : _focusController.reverse();
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _hoverController.dispose();
    _focusController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization = customizations.getTextField(widget.tag);

    if (customization == null) {
      return EditableText(
        controller: _controller,
        focusNode: _focusNode,
        style: const TextStyle(color: Color(0xFF000000)),
        cursorColor: const Color(0xFF000000),
        backgroundCursorColor: const Color(0xFFEEEEEE),
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
          cursor: SystemMouseCursors.text,
          child: GestureDetector(
            onTap: () => _focusNode.requestFocus(),
            child: Container(
              decoration: decoration,
              padding: const EdgeInsets.all(4.0),
              child: Stack(
                children: [
                  if (_controller.text.isEmpty && widget.placeholder != null)
                    Text(
                      widget.placeholder!,
                      style: textStyle.copyWith(
                        color: textStyle.color?.withValues(alpha: 0.5),
                      ),
                    ),
                  EditableText(
                    controller: _controller,
                    focusNode: _focusNode,
                    style: textStyle,
                    cursorColor:
                        customization.cursorColor ??
                        textStyle.color ??
                        const Color(0xFF000000),
                    backgroundCursorColor: const Color(0xFFEEEEEE),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
