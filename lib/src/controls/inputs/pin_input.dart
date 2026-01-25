import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';

import 'package:blankcanvas/src/foundation/status.dart';
import 'package:blankcanvas/src/theme/theme.dart';

/// A widget for entering a PIN or OTP code.
class PinInput extends LeafRenderObjectWidget {
  const PinInput({
    super.key,
    required this.length,
    required this.onChanged,
    required this.onCompleted,
    this.tag,
  });

  final int length;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onCompleted;
  final String? tag;

  @override
  RenderPinInput createRenderObject(BuildContext context) {
    return RenderPinInput(
      length: length,
      onChanged: onChanged,
      onCompleted: onCompleted,
      tag: tag,
      customization: CustomizedTheme.of(
        context,
      ).getTextField(tag), // Reuse text field customization? or new?
      // Theme likely doesn't have PinInput?
      // Reuse generic text field style for now or create new if needed.
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderPinInput renderObject) {
    renderObject
      ..length = length
      ..onChanged = onChanged
      ..onCompleted = onCompleted
      ..tag = tag
      ..customization = CustomizedTheme.of(context).getTextField(tag);
  }
}

class RenderPinInput extends RenderBox with TextInputClient {
  RenderPinInput({
    required int length,
    required ValueChanged<String> onChanged,
    required ValueChanged<String> onCompleted,
    String? tag,
    TextFieldCustomization? customization,
  }) : _length = length,
       _onChanged = onChanged,
       _onCompleted = onCompleted,
       _tag = tag,
       _customization = customization {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
    _controller = TextEditingController();
    _controller.addListener(_onControllerChanged);
  }

  int _length;
  set length(int value) {
    if (_length != value) {
      _length = value;
      markNeedsLayout();
    }
  }

  ValueChanged<String> _onChanged;
  set onChanged(ValueChanged<String> value) {
    _onChanged = value;
  }

  ValueChanged<String> _onCompleted;
  set onCompleted(ValueChanged<String> value) {
    _onCompleted = value;
  }

  String? _tag;
  set tag(String? value) {
    if (_tag != value) {
      _tag = value;
      markNeedsPaint();
    }
  }

  TextFieldCustomization? _customization;
  set customization(TextFieldCustomization? value) {
    if (_customization != value) {
      _customization = value;
      markNeedsPaint();
    }
  }

  late TextEditingController _controller;
  late TapGestureRecognizer _tap;
  TextInputConnection? _connection;
  final TextPainter _textPainter = TextPainter(
    textDirection: TextDirection.ltr,
  );

  // State
  bool _hasFocus = false;

  @override
  void detach() {
    _connection?.close();
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _tap.dispose();
    super.detach();
  }

  void _onControllerChanged() {
    if (_controller.text.length > _length) {
      _controller.text = _controller.text.substring(0, _length);
      _controller.selection = TextSelection.collapsed(offset: _length);
    }
    _onChanged(_controller.text);
    if (_controller.text.length == _length) {
      _onCompleted(_controller.text);
      // Auto unfocus?
      // _connection?.close();
    }
    markNeedsPaint();
    _connection?.setEditingState(_controller.value);
  }

  void _handleTapUp(TapUpDetails details) {
    _hasFocus = true;
    _openListConnection();
    markNeedsPaint();
  }

  void _openListConnection() {
    if (_connection == null || !_connection!.attached) {
      _connection = TextInput.attach(
        this,
        const TextInputConfiguration(inputType: TextInputType.number),
      );
      _connection!.setEditingState(_controller.value);
      _connection!.show();
    }
  }

  @override
  void performLayout() {
    // Layout N boxes.
    // Box size: 48x48. Spacing: 8.
    // Total width = (48 * length) + (8 * (length-1)).

    final boxSize = 48.0;
    final spacing = 8.0;
    final w = (boxSize * _length) + (spacing * (_length - 1));

    size = constraints.constrain(Size(w, boxSize));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final customization = _customization ?? TextFieldCustomization.simple();
    final status = MutableControlStatus()..focused = _hasFocus ? 1.0 : 0.0;
    final decoration = customization.decoration(status);
    final style = customization.textStyle(status); // centered text

    final boxSize = 48.0;
    final spacing = 8.0;

    for (int i = 0; i < _length; i++) {
      final x = offset.dx + (i * (boxSize + spacing));
      final rect = Rect.fromLTWH(x, offset.dy, boxSize, boxSize);

      // Draw box
      if (decoration is BoxDecoration) {
        final paint = Paint()
          ..color = decoration.color ?? const Color(0xFFE0E0E0);
        // Highlight current box if focused?
        // If i == current cursor index
        final isCurrent =
            _hasFocus &&
            i == _controller.selection.baseOffset; // rough approximation
        if (isCurrent) {
          paint.color = paint.color.withValues(alpha: 0.8);
        }

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

      // Draw text char
      if (i < _controller.text.length) {
        final char = _controller.text[i];
        _textPainter.text = TextSpan(text: char, style: style);
        _textPainter.layout();

        final dx = x + (boxSize - _textPainter.width) / 2;
        final dy = offset.dy + (boxSize - _textPainter.height) / 2;
        _textPainter.paint(canvas, Offset(dx, dy));
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

  // TextInputClient
  @override
  TextEditingValue? get currentTextEditingValue => _controller.value;
  @override
  AutofillScope? get currentAutofillScope => null;
  @override
  void updateEditingValue(TextEditingValue value) {
    _controller.value = value;
  }

  @override
  void performAction(TextInputAction action) {
    if (action == TextInputAction.done) {
      _connection?.close();
      _hasFocus = false;
      markNeedsPaint();
    }
  }

  @override
  void connectionClosed() {
    _connection = null;
    _hasFocus = false;
    markNeedsPaint();
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
