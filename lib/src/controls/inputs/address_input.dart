import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

/// An address input with structured fields.
class AddressInput extends LeafRenderObjectWidget {
  const AddressInput({
    super.key,
    this.onChanged,
    this.showCountry = true,
    this.tag,
  });

  final void Function(Address address)? onChanged;
  final bool showCountry;
  final String? tag;

  @override
  RenderAddressInput createRenderObject(BuildContext context) {
    return RenderAddressInput(onChanged: onChanged, showCountry: showCountry);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderAddressInput renderObject,
  ) {
    renderObject
      ..onChanged = onChanged
      ..showCountry = showCountry;
  }
}

class Address {
  const Address({
    this.street1 = '',
    this.street2 = '',
    this.city = '',
    this.state = '',
    this.postalCode = '',
    this.country = '',
  });

  final String street1;
  final String street2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
}

class RenderAddressInput extends RenderBox {
  RenderAddressInput({
    void Function(Address address)? onChanged,
    required bool showCountry,
  }) : _onChanged = onChanged,
       _showCountry = showCountry {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  void Function(Address address)?
  // ignore: unused_field
  _onChanged; // Kept as field for API consistency but ignored
  set onChanged(void Function(Address address)? value) => _onChanged = value;

  bool _showCountry;
  set showCountry(bool value) {
    if (_showCountry != value) {
      _showCountry = value;
      markNeedsLayout();
    }
  }

  late TapGestureRecognizer _tap;
  int _focusedField = 0;
  int? _hoveredField;

  final List<String> _values = ['', '', '', '', '', ''];
  static const List<String> _labels = [
    'Street Address',
    'Apt, Suite, etc.',
    'City',
    'State/Province',
    'Postal Code',
    'Country',
  ];
  static const List<String> _placeholders = [
    '123 Main St',
    'Apt 4B (optional)',
    'City',
    'State',
    '12345',
    'Country',
  ];

  static const double _fieldHeight = 44.0;
  static const double _spacing = 8.0;

  final List<Rect> _fieldRects = [];

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    _fieldRects.clear();
    final fieldCount = _showCountry ? 6 : 5; // ignore: unused_local_variable
    double y = 0;

    // Street 1 (full width)
    _fieldRects.add(Rect.fromLTWH(0, y, size.width, _fieldHeight));
    y += _fieldHeight + _spacing;

    // Street 2 (full width)
    _fieldRects.add(Rect.fromLTWH(0, y, size.width, _fieldHeight));
    y += _fieldHeight + _spacing;

    // City (60%) + State (40%)
    final cityWidth = size.width * 0.6 - _spacing / 2;
    final stateWidth = size.width * 0.4 - _spacing / 2;
    _fieldRects.add(Rect.fromLTWH(0, y, cityWidth, _fieldHeight));
    _fieldRects.add(
      Rect.fromLTWH(cityWidth + _spacing, y, stateWidth, _fieldHeight),
    );
    y += _fieldHeight + _spacing;

    // Postal (40%) + Country (60%)
    final postalWidth = size.width * 0.4 - _spacing / 2;
    _fieldRects.add(Rect.fromLTWH(0, y, postalWidth, _fieldHeight));
    if (_showCountry) {
      final countryWidth = size.width * 0.6 - _spacing / 2;
      _fieldRects.add(
        Rect.fromLTWH(postalWidth + _spacing, y, countryWidth, _fieldHeight),
      );
    }
    y += _fieldHeight;

    size = constraints.constrain(Size(constraints.maxWidth, y));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < _fieldRects.length; i++) {
      final rect = _fieldRects[i].shift(offset);
      final isFocused = _focusedField == i;
      final isHovered = _hoveredField == i;
      final value = _values[i];

      // Background
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        Paint()
          ..color = isHovered
              ? const Color(0xFFF9F9F9)
              : const Color(0xFFFFFFFF),
      );

      // Border
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = isFocused
              ? const Color(0xFF2196F3)
              : const Color(0xFFE0E0E0)
          ..strokeWidth = isFocused ? 2 : 1,
      );

      // Label (as floating label if has value)
      if (value.isNotEmpty) {
        textPainter.text = TextSpan(
          text: _labels[i],
          style: const TextStyle(fontSize: 10, color: Color(0xFF666666)),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(rect.left + 12, rect.top + 4));
      }

      // Value or placeholder
      textPainter.text = TextSpan(
        text: value.isEmpty ? _placeholders[i] : value,
        style: TextStyle(
          fontSize: 14,
          color: value.isEmpty
              ? const Color(0xFF999999)
              : const Color(0xFF333333),
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          rect.left + 12,
          rect.center.dy - textPainter.height / 2 + (value.isNotEmpty ? 4 : 0),
        ),
      );
    }
  }

  void _handleTapUp(TapUpDetails details) {
    final local = details.localPosition;
    for (int i = 0; i < _fieldRects.length; i++) {
      if (_fieldRects[i].contains(local)) {
        _focusedField = i;
        markNeedsPaint();
        return;
      }
    }
  }

  void _handleHover(PointerHoverEvent event) {
    final local = event.localPosition;
    int? hovered;
    for (int i = 0; i < _fieldRects.length; i++) {
      if (_fieldRects[i].contains(local)) {
        hovered = i;
        break;
      }
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
