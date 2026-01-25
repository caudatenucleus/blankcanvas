import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

/// A formatted phone number input.
class PhoneInput extends LeafRenderObjectWidget {
  const PhoneInput({
    super.key,
    this.onChanged,
    this.countryCode = '+1',
    this.placeholder = '(555) 123-4567',
    this.tag,
  });

  final ValueChanged<String>? onChanged;
  final String countryCode;
  final String placeholder;
  final String? tag;

  @override
  RenderPhoneInput createRenderObject(BuildContext context) {
    return RenderPhoneInput(
      onChanged: onChanged,
      countryCode: countryCode,
      placeholder: placeholder,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderPhoneInput renderObject) {
    renderObject
      ..onChanged = onChanged
      ..countryCode = countryCode
      ..placeholder = placeholder;
  }
}

class RenderPhoneInput extends RenderBox {
  RenderPhoneInput({
    ValueChanged<String>? onChanged,
    required String countryCode,
    required String placeholder,
  }) : _onChanged = onChanged,
       _countryCode = countryCode,
       _placeholder = placeholder {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  ValueChanged<String>? _onChanged;
  set onChanged(ValueChanged<String>? value) => _onChanged = value;

  String _countryCode;
  set countryCode(String value) {
    if (_countryCode != value) {
      _countryCode = value;
      markNeedsPaint();
    }
  }

  String _placeholder;
  set placeholder(String value) {
    if (_placeholder != value) {
      _placeholder = value;
      markNeedsPaint();
    }
  }

  late TapGestureRecognizer _tap;
  final String _phoneNumber = '';
  bool _countryHovered = false;

  static const double _countryWidth = 60.0;
  static const double _height = 40.0;

  Rect _countryRect = Rect.zero;
  Rect _inputRect = Rect.zero;

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    size = constraints.constrain(Size(constraints.maxWidth, _height));
    _countryRect = Rect.fromLTWH(0, 0, _countryWidth, _height);
    _inputRect = Rect.fromLTWH(
      _countryWidth,
      0,
      size.width - _countryWidth,
      _height,
    );
  }

  String _formatPhone(String digits) {
    if (digits.isEmpty) return '';
    if (digits.length <= 3) return '($digits';
    if (digits.length <= 6) {
      return '(${digits.substring(0, 3)}) ${digits.substring(3)}';
    }
    if (digits.length <= 10) {
      return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
    }
    return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6, 10)}';
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Country code box
    final countryRect = _countryRect.shift(offset);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        countryRect,
        topLeft: const Radius.circular(4),
        bottomLeft: const Radius.circular(4),
      ),
      Paint()
        ..color = _countryHovered
            ? const Color(0xFFEEEEEE)
            : const Color(0xFFF5F5F5),
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        countryRect,
        topLeft: const Radius.circular(4),
        bottomLeft: const Radius.circular(4),
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFFE0E0E0),
    );

    // Country code text
    textPainter.text = TextSpan(
      text: _countryCode,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF333333),
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        countryRect.left + 10,
        countryRect.center.dy - textPainter.height / 2,
      ),
    );

    // Dropdown arrow
    textPainter.text = const TextSpan(
      text: '▼',
      style: TextStyle(fontSize: 10, color: Color(0xFF757575)),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        countryRect.right - 16,
        countryRect.center.dy - textPainter.height / 2,
      ),
    );

    // Input box
    final inputRect = _inputRect.shift(offset);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        inputRect,
        topRight: const Radius.circular(4),
        bottomRight: const Radius.circular(4),
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFFE0E0E0),
    );

    // Phone number or placeholder
    final displayText = _phoneNumber.isEmpty
        ? _placeholder
        : _formatPhone(_phoneNumber);
    textPainter.text = TextSpan(
      text: displayText,
      style: TextStyle(
        fontSize: 14,
        color: _phoneNumber.isEmpty
            ? const Color(0xFF999999)
            : const Color(0xFF000000),
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(inputRect.left + 12, inputRect.center.dy - textPainter.height / 2),
    );
  }

  void _handleTapUp(TapUpDetails details) {
    // Tap handling for country picker would go here
  }

  void _handleHover(PointerHoverEvent event) {
    final wasHovered = _countryHovered;
    _countryHovered = _countryRect.contains(event.localPosition);
    if (wasHovered != _countryHovered) {
      markNeedsPaint();
    }
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _tap.addPointer(event);
    } else if (event is PointerHoverEvent) {
      _handleHover(event);
    }
  }
}
