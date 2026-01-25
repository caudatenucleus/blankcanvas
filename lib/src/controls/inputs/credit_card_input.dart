import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

/// A formatted credit card input with card number, expiry, and CVV.
class CreditCardInput extends LeafRenderObjectWidget {
  const CreditCardInput({
    super.key,
    this.onChanged,
    this.cardNumberPlaceholder = '0000 0000 0000 0000',
    this.expiryPlaceholder = 'MM/YY',
    this.cvvPlaceholder = 'CVV',
    this.tag,
  });

  final void Function(String cardNumber, String expiry, String cvv)? onChanged;
  final String cardNumberPlaceholder;
  final String expiryPlaceholder;
  final String cvvPlaceholder;
  final String? tag;

  @override
  RenderCreditCardInput createRenderObject(BuildContext context) {
    return RenderCreditCardInput(
      onChanged: onChanged,
      cardNumberPlaceholder: cardNumberPlaceholder,
      expiryPlaceholder: expiryPlaceholder,
      cvvPlaceholder: cvvPlaceholder,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderCreditCardInput renderObject,
  ) {
    renderObject
      ..onChanged = onChanged
      ..cardNumberPlaceholder = cardNumberPlaceholder
      ..expiryPlaceholder = expiryPlaceholder
      ..cvvPlaceholder = cvvPlaceholder;
  }
}

enum _CardType { visa, mastercard, amex, discover, unknown }

class RenderCreditCardInput extends RenderBox {
  RenderCreditCardInput({
    void Function(String cardNumber, String expiry, String cvv)? onChanged,
    required String cardNumberPlaceholder,
    required String expiryPlaceholder,
    required String cvvPlaceholder,
  }) : _onChanged = onChanged,
       _cardNumberPlaceholder = cardNumberPlaceholder,
       _expiryPlaceholder = expiryPlaceholder,
       _cvvPlaceholder = cvvPlaceholder {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  // ignore: unused_field
  void Function(String cardNumber, String expiry, String cvv)? _onChanged;
  set onChanged(
    void Function(String cardNumber, String expiry, String cvv)? value,
  ) => _onChanged = value;

  String _cardNumberPlaceholder;
  set cardNumberPlaceholder(String value) {
    _cardNumberPlaceholder = value;
    markNeedsPaint();
  }

  String _expiryPlaceholder;
  set expiryPlaceholder(String value) {
    _expiryPlaceholder = value;
    markNeedsPaint();
  }

  String _cvvPlaceholder;
  set cvvPlaceholder(String value) {
    _cvvPlaceholder = value;
    markNeedsPaint();
  }

  late TapGestureRecognizer _tap;

  final String _cardNumber = '';
  final String _expiry = '';
  final String _cvv = '';
  int _focusedField = 0; // 0=card, 1=expiry, 2=cvv
  int? _hoveredField;

  static const double _height = 56.0;
  static const double _cardWidth = 200.0;
  static const double _expiryWidth = 80.0;
  static const double _cvvWidth = 60.0;

  Rect _cardRect = Rect.zero;
  Rect _expiryRect = Rect.zero;
  Rect _cvvRect = Rect.zero;

  _CardType get _cardType {
    if (_cardNumber.isEmpty) return _CardType.unknown;
    if (_cardNumber.startsWith('4')) return _CardType.visa;
    if (_cardNumber.startsWith('5')) return _CardType.mastercard;
    if (_cardNumber.startsWith('3')) return _CardType.amex;
    if (_cardNumber.startsWith('6')) return _CardType.discover;
    return _CardType.unknown;
  }

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    size = constraints.constrain(
      Size(_cardWidth + _expiryWidth + _cvvWidth + 32, _height),
    );
    _cardRect = Rect.fromLTWH(0, 0, _cardWidth, _height);
    _expiryRect = Rect.fromLTWH(_cardWidth + 8, 0, _expiryWidth, _height);
    _cvvRect = Rect.fromLTWH(
      _cardWidth + _expiryWidth + 16,
      0,
      _cvvWidth,
      _height,
    );
  }

  String _formatCardNumber(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length && i < 16; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  String _formatExpiry(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length <= 2) return digits;
    return '${digits.substring(0, 2)}/${digits.substring(2, digits.length.clamp(2, 4))}';
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Card type icon
    String cardIcon = '💳';
    switch (_cardType) {
      case _CardType.visa:
        cardIcon = '💳V';
        break;
      case _CardType.mastercard:
        cardIcon = '💳M';
        break;
      case _CardType.amex:
        cardIcon = '💳A';
        break;
      case _CardType.discover:
        cardIcon = '💳D';
        break;
      default:
        break;
    }

    // Draw fields
    for (int i = 0; i < 3; i++) {
      final rect = [_cardRect, _expiryRect, _cvvRect][i].shift(offset);
      final isFocused = _focusedField == i;
      final isHovered = _hoveredField == i;

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        Paint()
          ..color = isHovered
              ? const Color(0xFFF5F5F5)
              : const Color(0xFFFFFFFF),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = isFocused
              ? const Color(0xFF2196F3)
              : const Color(0xFFE0E0E0)
          ..strokeWidth = isFocused ? 2 : 1,
      );

      String text, placeholder;
      if (i == 0) {
        text = _formatCardNumber(_cardNumber);
        placeholder = _cardNumberPlaceholder;
      } else if (i == 1) {
        text = _formatExpiry(_expiry);
        placeholder = _expiryPlaceholder;
      } else {
        text = _cvv.replaceAll(RegExp(r'.'), '•');
        placeholder = _cvvPlaceholder;
      }

      textPainter.text = TextSpan(
        text: text.isEmpty ? placeholder : text,
        style: TextStyle(
          fontSize: 14,
          color: text.isEmpty
              ? const Color(0xFF999999)
              : const Color(0xFF333333),
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(rect.left + 12, rect.center.dy - textPainter.height / 2),
      );
    }

    // Card type indicator
    textPainter.text = TextSpan(
      text: cardIcon,
      style: const TextStyle(fontSize: 16),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        offset.dx + _cardRect.right - textPainter.width - 8,
        offset.dy + _cardRect.center.dy - textPainter.height / 2,
      ),
    );
  }

  void _handleTapUp(TapUpDetails details) {
    final local = details.localPosition;
    if (_cardRect.contains(local)) {
      _focusedField = 0;
    } else if (_expiryRect.contains(local)) {
      _focusedField = 1;
    } else if (_cvvRect.contains(local)) {
      _focusedField = 2;
    }
    markNeedsPaint();
  }

  void _handleHover(PointerHoverEvent event) {
    final local = event.localPosition;
    int? hovered;
    if (_cardRect.contains(local)) {
      hovered = 0;
    } else if (_expiryRect.contains(local)) {
      hovered = 1;
    } else if (_cvvRect.contains(local)) {
      hovered = 2;
    }

    if (_hoveredField != hovered) {
      _hoveredField = hovered;
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
