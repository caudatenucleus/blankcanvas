import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

/// Currency data with code, name, and symbol.
class Currency {
  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
  });
  final String code;
  final String name;
  final String symbol;
}

/// A currency selector dropdown.
class CurrencySelector extends LeafRenderObjectWidget {
  const CurrencySelector({
    super.key,
    this.selectedCurrency,
    this.onChanged,
    this.currencies = defaultCurrencies,
    this.tag,
  });

  final Currency? selectedCurrency;
  final void Function(Currency currency)? onChanged;
  final List<Currency> currencies;
  final String? tag;

  static const List<Currency> defaultCurrencies = [
    Currency(code: 'USD', name: 'US Dollar', symbol: '\$'),
    Currency(code: 'EUR', name: 'Euro', symbol: '€'),
    Currency(code: 'GBP', name: 'British Pound', symbol: '£'),
    Currency(code: 'JPY', name: 'Japanese Yen', symbol: '¥'),
    Currency(code: 'CNY', name: 'Chinese Yuan', symbol: '¥'),
    Currency(code: 'INR', name: 'Indian Rupee', symbol: '₹'),
    Currency(code: 'CAD', name: 'Canadian Dollar', symbol: 'C\$'),
    Currency(code: 'AUD', name: 'Australian Dollar', symbol: 'A\$'),
    Currency(code: 'CHF', name: 'Swiss Franc', symbol: 'CHF'),
    Currency(code: 'KRW', name: 'South Korean Won', symbol: '₩'),
  ];

  @override
  RenderCurrencySelector createRenderObject(BuildContext context) {
    return RenderCurrencySelector(
      selectedCurrency: selectedCurrency,
      onChanged: onChanged,
      currencies: currencies,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderCurrencySelector renderObject,
  ) {
    renderObject
      ..selectedCurrency = selectedCurrency
      ..onChanged = onChanged
      ..currencies = currencies;
  }
}

class RenderCurrencySelector extends RenderBox {
  RenderCurrencySelector({
    Currency? selectedCurrency,
    void Function(Currency currency)? onChanged,
    required List<Currency> currencies,
  }) : _selectedCurrency = selectedCurrency,
       _onChanged = onChanged,
       _currencies = currencies {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  Currency? _selectedCurrency;
  set selectedCurrency(Currency? value) {
    _selectedCurrency = value;
    markNeedsPaint();
  }

  void Function(Currency currency)? _onChanged;
  set onChanged(void Function(Currency currency)? value) => _onChanged = value;

  List<Currency> _currencies;
  set currencies(List<Currency> value) {
    _currencies = value;
    markNeedsLayout();
  }

  late TapGestureRecognizer _tap;
  bool _isOpen = false;
  int? _hoveredIndex;

  static const double _buttonHeight = 44.0;
  static const double _itemHeight = 40.0;

  Rect _buttonRect = Rect.zero;
  final List<Rect> _itemRects = [];

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    _itemRects.clear();
    double height = _buttonHeight;
    if (_isOpen) {
      for (int i = 0; i < _currencies.length; i++) {
        _itemRects.add(Rect.fromLTWH(0, height, size.width, _itemHeight));
        height += _itemHeight;
      }
    }
    size = constraints.constrain(Size(constraints.maxWidth, height));
    _buttonRect = Rect.fromLTWH(0, 0, size.width, _buttonHeight);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Button
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        _buttonRect.shift(offset),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFFFFFFFF),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        _buttonRect.shift(offset),
        const Radius.circular(8),
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFFE0E0E0),
    );

    // Selected value
    final selected = _selectedCurrency;
    textPainter.text = TextSpan(
      text: selected != null
          ? '${selected.symbol} ${selected.code} - ${selected.name}'
          : 'Select currency...',
      style: TextStyle(
        fontSize: 14,
        color: selected != null
            ? const Color(0xFF333333)
            : const Color(0xFF999999),
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        offset.dx + 12,
        offset.dy + _buttonRect.center.dy - textPainter.height / 2,
      ),
    );

    // Dropdown arrow
    textPainter.text = TextSpan(
      text: _isOpen ? '▲' : '▼',
      style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        offset.dx + _buttonRect.right - 24,
        offset.dy + _buttonRect.center.dy - textPainter.height / 2,
      ),
    );

    // Dropdown items
    if (_isOpen) {
      final dropdownRect = Rect.fromLTWH(
        offset.dx,
        offset.dy + _buttonHeight,
        size.width,
        _currencies.length * _itemHeight,
      );
      final shadowPath = Path()
        ..addRRect(
          RRect.fromRectAndRadius(dropdownRect, const Radius.circular(8)),
        );
      canvas.drawShadow(shadowPath, const Color(0xFF000000), 8, false);
      canvas.drawRRect(
        RRect.fromRectAndRadius(dropdownRect, const Radius.circular(8)),
        Paint()..color = const Color(0xFFFFFFFF),
      );

      for (int i = 0; i < _currencies.length; i++) {
        if (i >= _itemRects.length) break;
        final itemRect = _itemRects[i].shift(offset);
        final currency = _currencies[i];
        final isHovered = _hoveredIndex == i;

        if (isHovered) {
          canvas.drawRect(itemRect, Paint()..color = const Color(0xFFF5F5F5));
        }

        textPainter.text = TextSpan(
          text: '${currency.symbol} ${currency.code}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333),
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            itemRect.left + 12,
            itemRect.center.dy - textPainter.height / 2,
          ),
        );

        textPainter.text = TextSpan(
          text: currency.name,
          style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            itemRect.right - textPainter.width - 12,
            itemRect.center.dy - textPainter.height / 2,
          ),
        );
      }
    }
  }

  void _handleTapUp(TapUpDetails details) {
    final local = details.localPosition;

    if (_buttonRect.contains(local)) {
      _isOpen = !_isOpen;
      markNeedsLayout();
      return;
    }

    if (_isOpen) {
      for (int i = 0; i < _itemRects.length; i++) {
        if (_itemRects[i].contains(local)) {
          _selectedCurrency = _currencies[i];
          _isOpen = false;
          _onChanged?.call(_currencies[i]);
          markNeedsLayout();
          return;
        }
      }
    }
  }

  void _handleHover(PointerHoverEvent event) {
    if (!_isOpen) return;
    final local = event.localPosition;
    int? hovered;
    for (int i = 0; i < _itemRects.length; i++) {
      if (_itemRects[i].contains(local)) {
        hovered = i;
        break;
      }
    }
    if (_hoveredIndex != hovered) {
      _hoveredIndex = hovered;
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
