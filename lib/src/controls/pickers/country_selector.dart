import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

/// Country data with code, name, and flag emoji.
class Country {
  const Country({
    required this.code,
    required this.name,
    required this.flag,
    this.dialCode,
  });
  final String code;
  final String name;
  final String flag;
  final String? dialCode;
}

/// A country selector dropdown.
class CountrySelector extends LeafRenderObjectWidget {
  const CountrySelector({
    super.key,
    this.selectedCountry,
    this.onChanged,
    this.countries = defaultCountries,
    this.tag,
  });

  final Country? selectedCountry;
  final void Function(Country country)? onChanged;
  final List<Country> countries;
  final String? tag;

  static const List<Country> defaultCountries = [
    Country(code: 'US', name: 'United States', flag: '🇺🇸', dialCode: '+1'),
    Country(code: 'GB', name: 'United Kingdom', flag: '🇬🇧', dialCode: '+44'),
    Country(code: 'CA', name: 'Canada', flag: '🇨🇦', dialCode: '+1'),
    Country(code: 'AU', name: 'Australia', flag: '🇦🇺', dialCode: '+61'),
    Country(code: 'DE', name: 'Germany', flag: '🇩🇪', dialCode: '+49'),
    Country(code: 'FR', name: 'France', flag: '🇫🇷', dialCode: '+33'),
    Country(code: 'JP', name: 'Japan', flag: '🇯🇵', dialCode: '+81'),
    Country(code: 'CN', name: 'China', flag: '🇨🇳', dialCode: '+86'),
    Country(code: 'IN', name: 'India', flag: '🇮🇳', dialCode: '+91'),
    Country(code: 'BR', name: 'Brazil', flag: '🇧🇷', dialCode: '+55'),
  ];

  @override
  RenderCountrySelector createRenderObject(BuildContext context) {
    return RenderCountrySelector(
      selectedCountry: selectedCountry,
      onChanged: onChanged,
      countries: countries,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderCountrySelector renderObject,
  ) {
    renderObject
      ..selectedCountry = selectedCountry
      ..onChanged = onChanged
      ..countries = countries;
  }
}

class RenderCountrySelector extends RenderBox {
  RenderCountrySelector({
    Country? selectedCountry,
    void Function(Country country)? onChanged,
    required List<Country> countries,
  }) : _selectedCountry = selectedCountry,
       _onChanged = onChanged,
       _countries = countries {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  Country? _selectedCountry;
  set selectedCountry(Country? value) {
    _selectedCountry = value;
    markNeedsPaint();
  }

  void Function(Country country)? _onChanged;
  set onChanged(void Function(Country country)? value) => _onChanged = value;

  List<Country> _countries;
  set countries(List<Country> value) {
    _countries = value;
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
      for (int i = 0; i < _countries.length; i++) {
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
    final selected = _selectedCountry;
    textPainter.text = TextSpan(
      text: selected != null
          ? '${selected.flag} ${selected.name}'
          : 'Select country...',
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
      // Shadow background
      final dropdownRect = Rect.fromLTWH(
        offset.dx,
        offset.dy + _buttonHeight,
        size.width,
        _countries.length * _itemHeight,
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

      for (int i = 0; i < _countries.length; i++) {
        if (i >= _itemRects.length) break;
        final itemRect = _itemRects[i].shift(offset);
        final country = _countries[i];
        final isHovered = _hoveredIndex == i;

        if (isHovered) {
          canvas.drawRect(itemRect, Paint()..color = const Color(0xFFF5F5F5));
        }

        textPainter.text = TextSpan(
          text: '${country.flag} ${country.name}',
          style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            itemRect.left + 12,
            itemRect.center.dy - textPainter.height / 2,
          ),
        );

        if (country.dialCode != null) {
          textPainter.text = TextSpan(
            text: country.dialCode,
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
          _selectedCountry = _countries[i];
          _isOpen = false;
          _onChanged?.call(_countries[i]);
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
