// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';


class RenderUnitConverter extends RenderBox {
  RenderUnitConverter({
    required String category,
    void Function(double result, String fromUnit, String toUnit)? onConvert,
  }) : _category = category,
       _onConvert = onConvert {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  String _category;
  set category(String value) {
    if (_category != value) {
      _category = value;
      _fromUnit = _units[_category]?.first ?? '';
      _toUnit = _units[_category]?.elementAt(1) ?? '';
      markNeedsPaint();
    }
  }

  void Function(double result, String fromUnit, String toUnit)? _onConvert;
  set onConvert(
    void Function(double result, String fromUnit, String toUnit)? value,
  ) => _onConvert = value;

  late TapGestureRecognizer _tap;

  final double _inputValue = 1;
  String _fromUnit = 'm';
  String _toUnit = 'ft';
  int? _hoveredButton;

  static const Map<String, List<String>> _units = {
    'length': ['m', 'cm', 'mm', 'km', 'in', 'ft', 'yd', 'mi'],
    'weight': ['kg', 'g', 'mg', 'lb', 'oz', 't'],
    'temperature': ['°C', '°F', 'K'],
    'volume': ['L', 'mL', 'gal', 'qt', 'pt', 'cup'],
  };

  static const Map<String, Map<String, double>> _toBase = {
    'length': {
      'm': 1,
      'cm': 0.01,
      'mm': 0.001,
      'km': 1000,
      'in': 0.0254,
      'ft': 0.3048,
      'yd': 0.9144,
      'mi': 1609.344,
    },
    'weight': {
      'kg': 1,
      'g': 0.001,
      'mg': 0.000001,
      'lb': 0.453592,
      'oz': 0.0283495,
      't': 1000,
    },
    'volume': {
      'L': 1,
      'mL': 0.001,
      'gal': 3.78541,
      'qt': 0.946353,
      'pt': 0.473176,
      'cup': 0.236588,
    },
  };

  static const double _rowHeight = 48.0;
  static const double _swapButtonSize = 40.0;

  Rect _fromRect = Rect.zero;
  Rect _toRect = Rect.zero;
  Rect _swapRect = Rect.zero;

  double get _result {
    if (_category == 'temperature') {
      return _convertTemperature(_inputValue, _fromUnit, _toUnit);
    }
    final baseValue = _inputValue * (_toBase[_category]?[_fromUnit] ?? 1);
    return baseValue / (_toBase[_category]?[_toUnit] ?? 1);
  }

  double _convertTemperature(double value, String from, String to) {
    double celsius;
    if (from == '°C') {
      celsius = value;
    } else if (from == '°F')
      celsius = (value - 32) * 5 / 9;
    else
      celsius = value - 273.15;

    if (to == '°C') return celsius;
    if (to == '°F') return celsius * 9 / 5 + 32;
    return celsius + 273.15;
  }

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    size = constraints.constrain(
      Size(constraints.maxWidth, _rowHeight * 2 + 16),
    );
    _fromRect = Rect.fromLTWH(
      0,
      0,
      (size.width - _swapButtonSize - 16) / 2,
      _rowHeight,
    );
    _swapRect = Rect.fromLTWH(
      _fromRect.right + 8,
      (_rowHeight * 2 - _swapButtonSize) / 2,
      _swapButtonSize,
      _swapButtonSize,
    );
    _toRect = Rect.fromLTWH(
      _swapRect.right + 8,
      0,
      (size.width - _swapButtonSize - 16) / 2,
      _rowHeight,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // From box
    _drawUnitBox(
      canvas,
      _fromRect.shift(offset),
      _inputValue.toString(),
      _fromUnit,
      'From',
    );

    // Swap button
    final swapRect = _swapRect.shift(offset);
    canvas.drawRRect(
      RRect.fromRectAndRadius(swapRect, const Radius.circular(20)),
      Paint()
        ..color = _hoveredButton == 0
            ? const Color(0xFF2196F3)
            : const Color(0xFFEEEEEE),
    );
    textPainter.text = TextSpan(
      text: '⇄',
      style: TextStyle(
        fontSize: 20,
        color: _hoveredButton == 0
            ? const Color(0xFFFFFFFF)
            : const Color(0xFF666666),
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      swapRect.center - Offset(textPainter.width / 2, textPainter.height / 2),
    );

    // To box
    _drawUnitBox(
      canvas,
      _toRect.shift(offset),
      _result.toStringAsFixed(4),
      _toUnit,
      'To',
    );

    // Category label
    textPainter.text = TextSpan(
      text: _category.toUpperCase(),
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: Color(0xFF999999),
        letterSpacing: 1,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(offset.dx, offset.dy + _rowHeight + 8));
  }

  void _drawUnitBox(
    Canvas canvas,
    Rect rect,
    String value,
    String unit,
    String label,
  ) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      Paint()..color = const Color(0xFFF5F5F5),
    );

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Label
    textPainter.text = TextSpan(
      text: label,
      style: const TextStyle(fontSize: 10, color: Color(0xFF999999)),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(rect.left + 12, rect.top + 4));

    // Value
    textPainter.text = TextSpan(
      text: value,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF333333),
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(rect.left + 12, rect.center.dy - textPainter.height / 2 + 4),
    );

    // Unit
    textPainter.text = TextSpan(
      text: unit,
      style: const TextStyle(fontSize: 14, color: Color(0xFF2196F3)),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        rect.right - textPainter.width - 12,
        rect.center.dy - textPainter.height / 2 + 4,
      ),
    );
  }

  void _handleTapUp(TapUpDetails details) {
    final local = details.localPosition;
    if (_swapRect.contains(local)) {
      final temp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = temp;
      _onConvert?.call(_result, _fromUnit, _toUnit);
      markNeedsPaint();
    }
  }

  void _handleHover(PointerHoverEvent event) {
    final local = event.localPosition;
    final hovered = _swapRect.contains(local) ? 0 : null;
    if (_hoveredButton != hovered) {
      _hoveredButton = hovered;
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
