import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

import '../foundation/status.dart';
import '../theme/customization.dart';
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

class _TextFieldState extends State<TextField>
    with TickerProviderStateMixin, TextInputClient {
  final TextFieldStatus _status = TextFieldStatus();
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  TextInputConnection? _connection;

  late final AnimationController _hoverController;
  late final AnimationController _focusController;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onControllerChanged);

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

    _focusNode.addListener(_onFocusNodeChanged);
  }

  void _onControllerChanged() {
    setState(() {});
    _connection?.setEditingState(_controller.value);
  }

  void _onFocusNodeChanged() {
    if (_focusNode.hasFocus) {
      _focusController.forward();
      _connection = TextInput.attach(this, const TextInputConfiguration());
      _connection?.setEditingState(_controller.value);
      _connection?.show();
    } else {
      _focusController.reverse();
      _connection?.close();
      _connection = null;
    }
  }

  @override
  void updateEditingValue(TextEditingValue value) {
    _controller.value = value;
  }

  @override
  void performAction(TextInputAction action) {
    _focusNode.unfocus();
  }

  @override
  AutofillScope? get currentAutofillScope => null;

  @override
  TextEditingValue? get currentTextEditingValue => _controller.value;

  @override
  void showAutocorrectionPromptRect(int start, int end) {}

  @override
  void updateFloatingCursor(RawFloatingCursorPoint point) {}

  @override
  void showToolbar() {}

  @override
  void insertTextPlaceholder(Size size) {}

  @override
  void removeTextPlaceholder() {}

  @override
  void performPrivateCommand(String action, Map<String, dynamic> data) {}

  @override
  void connectionClosed() {
    _connection = null;
  }

  @override
  void didUpdateWidget(TextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      _controller = widget.controller ?? TextEditingController();
      _controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    if (widget.controller == null) _controller.dispose();
    _hoverController.dispose();
    _focusController.dispose();
    _focusNode.dispose();
    _connection?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization =
        customizations.getTextField(widget.tag) ??
        TextFieldCustomization.simple();

    return Semantics(
      textField: true,
      label: widget.placeholder,
      value: _controller.text,
      child: MouseRegion(
        onEnter: (_) => _hoverController.forward(),
        onExit: (_) => _hoverController.reverse(),
        cursor: SystemMouseCursors.text,
        child: GestureDetector(
          onTap: () => _focusNode.requestFocus(),
          child: _TextFieldRenderWidget(
            value: _controller.value,
            placeholder: widget.placeholder,
            status: _status,
            customization: customization,
            focusNode: _focusNode,
          ),
        ),
      ),
    );
  }
}

class _TextFieldRenderWidget extends LeafRenderObjectWidget {
  const _TextFieldRenderWidget({
    required this.value,
    this.placeholder,
    required this.status,
    required this.customization,
    required this.focusNode,
  });

  final TextEditingValue value;
  final String? placeholder;
  final TextFieldStatus status;
  final TextFieldCustomization customization;
  final FocusNode focusNode;

  @override
  RenderTextField createRenderObject(BuildContext context) {
    return RenderTextField(
      value: value,
      placeholder: placeholder,
      status: status,
      customization: customization,
      focusNode: focusNode,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderTextField renderObject,
  ) {
    renderObject
      ..value = value
      ..placeholder = placeholder
      ..status = status
      ..customization = customization
      ..focusNode = focusNode;
  }
}

class RenderTextField extends RenderBox {
  RenderTextField({
    required TextEditingValue value,
    String? placeholder,
    required TextFieldStatus status,
    required TextFieldCustomization customization,
    required FocusNode focusNode,
  }) : _value = value,
       _placeholder = placeholder,
       _status = status,
       _customization = customization,
       _focusNode = focusNode {
    _status.addListener(markNeedsPaint);
  }

  TextEditingValue _value;
  TextEditingValue get value => _value;
  set value(TextEditingValue val) {
    if (_value == val) return;
    _value = val;
    markNeedsLayout();
  }

  String? _placeholder;
  String? get placeholder => _placeholder;
  set placeholder(String? val) {
    if (_placeholder == val) return;
    _placeholder = val;
    markNeedsLayout();
  }

  TextFieldStatus _status;
  TextFieldStatus get status => _status;
  set status(TextFieldStatus val) {
    if (_status == val) return;
    _status.removeListener(markNeedsPaint);
    _status = val;
    _status.addListener(markNeedsPaint);
    markNeedsPaint();
  }

  TextFieldCustomization _customization;
  TextFieldCustomization get customization => _customization;
  set customization(TextFieldCustomization val) {
    _customization = val;
    markNeedsPaint();
  }

  FocusNode _focusNode;
  FocusNode get focusNode => _focusNode;
  set focusNode(FocusNode val) {
    _focusNode = val;
    markNeedsPaint();
  }

  final TextPainter _textPainter = TextPainter(
    textDirection: TextDirection.ltr,
  );

  @override
  void performLayout() {
    final style = customization.textStyle(status);
    final displayedText = value.text.isEmpty ? (placeholder ?? "") : value.text;
    final displayStyle = value.text.isEmpty && placeholder != null
        ? style.copyWith(color: style.color?.withValues(alpha: 0.5))
        : style;

    _textPainter.text = TextSpan(text: displayedText, style: displayStyle);
    _textPainter.layout(maxWidth: constraints.maxWidth);

    final height = _textPainter.height + 16; // Padding
    size = constraints.constrain(Size(constraints.maxWidth, height));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final decoration = customization.decoration(status);
    final rect = offset & size;

    // Decoration
    if (decoration is BoxDecoration) {
      final paint = Paint()
        ..color = decoration.color ?? const Color(0xFFFFFFFF);
      if (decoration.borderRadius != null) {
        canvas.drawRRect(
          decoration.borderRadius!.resolve(TextDirection.ltr).toRRect(rect),
          paint,
        );
      } else {
        canvas.drawRect(rect, paint);
      }
      if (decoration.border != null) {
        decoration.border!.paint(canvas, rect);
      }
    }

    // Text
    _textPainter.paint(canvas, offset + const Offset(8, 8));

    // Cursor
    if (focusNode.hasFocus && value.selection.isCollapsed) {
      final cursorOffset = _textPainter.getOffsetForCaret(
        TextPosition(offset: value.selection.baseOffset),
        Rect.zero,
      );
      final paint = Paint()
        ..color =
            customization.cursorColor ??
            customization.textStyle(status).color ??
            const Color(0xFF000000)
        ..strokeWidth = 2;
      canvas.drawLine(
        offset + const Offset(8, 8) + cursorOffset,
        offset +
            const Offset(8, 8) +
            cursorOffset +
            Offset(0, _textPainter.height),
        paint,
      );
    }
  }

  @override
  void detach() {
    _status.removeListener(markNeedsPaint);
    super.detach();
  }
}
