import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';

import 'package:blankcanvas/src/foundation/status.dart';
import 'package:blankcanvas/src/theme/theme.dart';

/// Status for a TextField.
class TextFieldStatus extends MutableControlStatus {}

class TextField extends LeafRenderObjectWidget {
  const TextField({
    super.key,
    this.controller,
    this.tag,
    this.placeholder,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.inputFormatters,
    this.textAlign = TextAlign.start,
    this.focusNode,
    this.obscureText = false,
  });

  final TextEditingController? controller;
  final String? tag;
  final String? placeholder;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextAlign textAlign;
  final FocusNode? focusNode;
  final bool obscureText;

  @override
  RenderTextField createRenderObject(BuildContext context) {
    return RenderTextField(
      controller: controller,
      tag: tag,
      placeholder: placeholder,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textAlign: textAlign,
      focusNode: focusNode,
      obscureText: obscureText,
      customization: CustomizedTheme.of(context).getTextField(tag),
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderTextField renderObject) {
    renderObject
      ..controller = controller
      ..tag = tag
      ..placeholder = placeholder
      ..onChanged = onChanged
      ..onSubmitted = onSubmitted
      ..keyboardType = keyboardType
      ..inputFormatters = inputFormatters
      ..textAlign = textAlign
      ..focusNode = focusNode
      ..obscureText = obscureText
      ..customization = CustomizedTheme.of(context).getTextField(tag);
  }
}

class RenderTextField extends RenderBox with TextInputClient {
  RenderTextField({
    TextEditingController? controller,
    String? tag,
    String? placeholder,
    this.onChanged,
    this.onSubmitted,
    TextInputType? keyboardType,
    this.inputFormatters,
    TextAlign textAlign = TextAlign.start,
    FocusNode? focusNode,
    bool obscureText = false,
    TextFieldCustomization? customization,
  }) : _userController = controller,
       _tag = tag,
       _placeholder = placeholder,
       _keyboardType = keyboardType,
       _textAlign = textAlign,
       _userFocusNode = focusNode,
       _obscureText = obscureText,
       _customization = customization {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;

    // Initialize local if needed
    _controller = _userController ?? TextEditingController();
    _focusNode = _userFocusNode ?? FocusNode();

    // Listeners will be accumulated in attach
  }

  TextEditingController? _userController;
  late TextEditingController _controller;
  TextEditingController get controller => _controller; // Expose getter
  set controller(TextEditingController? value) {
    if (_userController != value) {
      _userController = value;
      _cleanUpController();
      _controller = _userController ?? TextEditingController();
      if (attached) _controller.addListener(_onControllerChanged);
      markNeedsLayout();
    }
  }

  FocusNode? _userFocusNode;
  late FocusNode _focusNode;
  FocusNode get focusNode => _focusNode; // Expose getter
  set focusNode(FocusNode? value) {
    if (_userFocusNode != value) {
      _userFocusNode = value;
      _cleanUpFocusNode();
      _focusNode = _userFocusNode ?? FocusNode();
      if (attached) _focusNode.addListener(_onFocusChanged);
      markNeedsPaint();
    }
  }

  String? _tag;
  set tag(String? value) {
    if (_tag != value) {
      _tag = value;
      markNeedsPaint();
    }
  }

  String? _placeholder;
  set placeholder(String? value) {
    if (_placeholder != value) {
      _placeholder = value;
      markNeedsLayout();
    }
  }

  ValueChanged<String>? onChanged;

  ValueChanged<String>? onSubmitted;

  TextInputType? _keyboardType;
  set keyboardType(TextInputType? value) {
    if (_keyboardType != value) {
      _keyboardType = value;
      if (_connection != null && _connection!.attached) {
        _connection!.updateConfig(_inputConfiguration);
      }
    }
  }

  List<TextInputFormatter>? inputFormatters;

  TextAlign _textAlign;
  set textAlign(TextAlign value) {
    if (_textAlign != value) {
      _textAlign = value;
      markNeedsLayout();
    }
  }

  bool _obscureText;
  set obscureText(bool value) {
    if (_obscureText != value) {
      _obscureText = value;
      markNeedsLayout();
    }
  }

  TextFieldCustomization? _customization;
  set customization(TextFieldCustomization? value) {
    if (_customization != value) {
      _customization = value;
      markNeedsPaint();
    }
  }

  // State
  late TapGestureRecognizer _tap;
  TextInputConnection? _connection;
  final TextFieldStatus _status = TextFieldStatus();
  final TextPainter _textPainter = TextPainter(
    textDirection: TextDirection.ltr,
  );

  TextEditingValue get value => _controller.value;

  void _cleanUpController() {
    if (_userController == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onControllerChanged);
    }
  }

  void _cleanUpFocusNode() {
    if (_userFocusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChanged);
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _controller.addListener(_onControllerChanged);
    _focusNode.addListener(_onFocusChanged);
    _status.addListener(markNeedsPaint);
    // Initial status
    if (_focusNode.hasFocus) {
      _status.focused = 1.0;
      _openListConnection();
    }
  }

  @override
  void detach() {
    _status.removeListener(markNeedsPaint);
    _controller.removeListener(_onControllerChanged);
    _focusNode.removeListener(_onFocusChanged);
    _cleanUpController();
    _cleanUpFocusNode();
    _tap.dispose();
    _connection?.close();
    super.detach();
  }

  void _onControllerChanged() {
    markNeedsLayout();
    // Logic to sync with connection?
    // Usually controller listeners are internal.
    // If text changed, we might need to tell IME if it wasn't IME initiated.
    // Logic: if connection exists, setEditingState.
    _connection?.setEditingState(_controller.value);
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _status.focused = 1.0;
      _openListConnection();
    } else {
      _status.focused = 0.0;
      _connection?.close();
      _connection = null;
    }
    markNeedsPaint(); // Cursor visibility
  }

  void _handleTapUp(TapUpDetails details) {
    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
    } else {
      // Move cursor logic potentially
      // Need to tapToPosition
      // _textPainter has layout.
      // Get offset in text.
      // _controller.selection = ...
    }
  }

  TextInputConfiguration get _inputConfiguration => TextInputConfiguration(
    inputType: _keyboardType ?? TextInputType.text,
    obscureText: _obscureText,
    inputAction: onSubmitted != null
        ? TextInputAction.done
        : TextInputAction.newline,
  );

  void _openListConnection() {
    if (_connection == null || !_connection!.attached) {
      _connection = TextInput.attach(this, _inputConfiguration);
      _connection!.setEditingState(_controller.value);
      _connection!.show();
    }
  }

  @override
  void performLayout() {
    _textPainter.textAlign = _textAlign;
    final customization = _customization ?? TextFieldCustomization.simple();
    final style = customization.textStyle(_status);

    String textToDisplay = _controller.text;
    TextStyle textStyle = style;

    if (textToDisplay.isEmpty) {
      textToDisplay = _placeholder ?? "";
      textStyle = style.copyWith(color: style.color?.withValues(alpha: 0.5));
    } else if (_obscureText) {
      textToDisplay = "•" * textToDisplay.length;
    }

    _textPainter.text = TextSpan(text: textToDisplay, style: textStyle);
    _textPainter.layout(maxWidth: constraints.maxWidth - 16); // padding

    final height = _textPainter.height + 16;
    size = constraints.constrain(Size(constraints.maxWidth, height));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final customization = _customization ?? TextFieldCustomization.simple();
    final decoration = customization.decoration(_status);
    final rect = offset & size;

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

    _textPainter.paint(canvas, offset + const Offset(8, 8)); // padding

    // Cursor
    if (_focusNode.hasFocus && _controller.selection.isCollapsed) {
      // Calculate cursor offset
      final visibleText = _obscureText
          ? "•" * _controller.text.length
          : _controller.text;
      // TextPainter has the layout for visibleText (from performLayout).
      // BUT _controller.selection refers to original text.
      // If obscure, selection maps 1:1 usually.

      final selectionIndex = _controller.selection.baseOffset;
      if (selectionIndex >= 0 && selectionIndex <= visibleText.length) {
        final caretOffset = _textPainter.getOffsetForCaret(
          TextPosition(offset: selectionIndex),
          Rect.zero,
        );
        final cursorPaint = Paint()
          ..color = customization.cursorColor ?? const Color(0xFF000000)
          ..strokeWidth = 2;

        final cTop = offset + const Offset(8, 8) + caretOffset;
        // cBottom was unused

        // _textPainter.preferredLineHeight is better
        canvas.drawLine(
          cTop,
          cTop + Offset(0, _textPainter.preferredLineHeight),
          cursorPaint,
        );
      }
    }
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _tap.addPointer(event);
    }
  }

  // TextInputClient implementation

  @override
  TextEditingValue? get currentTextEditingValue => _controller.value;

  @override
  AutofillScope? get currentAutofillScope => null;

  @override
  void updateEditingValue(TextEditingValue value) {
    TextEditingValue formattedValue = value;
    if (inputFormatters != null) {
      for (final formatter in inputFormatters!) {
        formattedValue = formatter.formatEditUpdate(
          _controller.value,
          formattedValue,
        );
      }
    }
    _controller.value = formattedValue;
    onChanged?.call(_controller.text);
  }

  @override
  void performAction(TextInputAction action) {
    if (action == TextInputAction.done && onSubmitted != null) {
      onSubmitted!(_controller.text);
      _focusNode.unfocus();
    }
  }

  @override
  void connectionClosed() {
    _connection = null;
  }

  @override
  void performPrivateCommand(String action, Map<String, dynamic> data) {}

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
}
