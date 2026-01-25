import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

/// A formatted currency input.
class CurrencyInput extends LeafRenderObjectWidget {
  const CurrencyInput({
    super.key,
    this.onChanged,
    this.currencySymbol = '\$',
    this.decimalPlaces = 2,
    this.thousandsSeparator = ',',
    this.placeholder = '0.00',
    this.tag,
  });

  final ValueChanged<double>? onChanged;
  final String currencySymbol;
  final int decimalPlaces;
  final String thousandsSeparator;
  final String placeholder;
  final String? tag;

  @override
  RenderCurrencyInput createRenderObject(BuildContext context) {
    return RenderCurrencyInput(
      onChanged: onChanged,
      currencySymbol: currencySymbol,
      decimalPlaces: decimalPlaces,
      thousandsSeparator: thousandsSeparator,
      placeholder: placeholder,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderCurrencyInput renderObject,
  ) {
    renderObject
      ..onChanged = onChanged
      ..currencySymbol = currencySymbol
      ..decimalPlaces = decimalPlaces
      ..thousandsSeparator = thousandsSeparator
      ..placeholder = placeholder;
  }
}

class RenderCurrencyInput extends RenderBox {
  RenderCurrencyInput({
    ValueChanged<double>? onChanged,
    required String currencySymbol,
    required int decimalPlaces,
    required String thousandsSeparator,
    required String placeholder,
  }) : _onChanged = onChanged,
       _currencySymbol = currencySymbol,
       _decimalPlaces = decimalPlaces,
       _thousandsSeparator = thousandsSeparator,
       _placeholder = placeholder {
    _tap = TapGestureRecognizer()..onTap = _handleTap;
  }

  ValueChanged<double>? _onChanged;
  set onChanged(ValueChanged<double>? value) => _onChanged = value;

  String _currencySymbol;
  set currencySymbol(String value) {
    if (_currencySymbol != value) {
      _currencySymbol = value;
      markNeedsPaint();
    }
  }

  int _decimalPlaces;
  set decimalPlaces(int value) => _decimalPlaces = value;

  String _thousandsSeparator;
  set thousandsSeparator(String value) => _thousandsSeparator = value;

  String _placeholder;
  set placeholder(String value) {
    if (_placeholder != value) {
      _placeholder = value;
      markNeedsPaint();
    }
  }

  late TapGestureRecognizer _tap;
  final String _value = '';
  bool _symbolHovered = false;

  static const double _symbolWidth = 40.0;
  static const double _height = 40.0;

  Rect _symbolRect = Rect.zero;
  Rect _inputRect = Rect.zero;

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    size = constraints.constrain(Size(constraints.maxWidth, _height));
    _symbolRect = Rect.fromLTWH(0, 0, _symbolWidth, _height);
    _inputRect = Rect.fromLTWH(
      _symbolWidth,
      0,
      size.width - _symbolWidth,
      _height,
    );
  }

  String _formatValue() {
    if (_value.isEmpty) return '';
    final value = double.tryParse(_value) ?? 0;
    final parts = value.toStringAsFixed(_decimalPlaces).split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}$_thousandsSeparator',
    );
    return _decimalPlaces > 0 ? '$intPart.${parts[1]}' : intPart;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Border
    canvas.drawRRect(
      RRect.fromRectAndRadius(offset & size, const Radius.circular(4)),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFFE0E0E0),
    );

    // Symbol box
    final symbolRect = _symbolRect.shift(offset);
    canvas.drawRect(
      symbolRect,
      Paint()
        ..color = _symbolHovered
            ? const Color(0xFFEEEEEE)
            : const Color(0xFFF5F5F5),
    );
    canvas.drawLine(
      Offset(symbolRect.right, symbolRect.top),
      Offset(symbolRect.right, symbolRect.bottom),
      Paint()..color = const Color(0xFFE0E0E0),
    );

    // Symbol text
    textPainter.text = TextSpan(
      text: _currencySymbol,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF666666),
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        symbolRect.center.dx - textPainter.width / 2,
        symbolRect.center.dy - textPainter.height / 2,
      ),
    );

    // Input value
    final inputRect = _inputRect.shift(offset);
    final displayText = _value.isEmpty ? _placeholder : _formatValue();
    textPainter.text = TextSpan(
      text: displayText,
      style: TextStyle(
        fontSize: 14,
        color: _value.isEmpty
            ? const Color(0xFF999999)
            : const Color(0xFF000000),
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        inputRect.right - textPainter.width - 12,
        inputRect.center.dy - textPainter.height / 2,
      ),
    );
  }

  void _handleTap() {
    // Focus handling would go here
  }

  void _handleHover(PointerHoverEvent event) {
    final wasHovered = _symbolHovered;
    _symbolHovered = _symbolRect.contains(event.localPosition);
    if (wasHovered != _symbolHovered) {
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
