import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

/// A font picker dropdown.
class FontPicker extends LeafRenderObjectWidget {
  const FontPicker({
    super.key,
    this.selectedFont,
    this.onChanged,
    this.fonts = defaultFonts,
    this.tag,
  });

  final String? selectedFont;
  final void Function(String fontFamily)? onChanged;
  final List<String> fonts;
  final String? tag;

  static const List<String> defaultFonts = [
    'Roboto',
    'Open Sans',
    'Lato',
    'Montserrat',
    'Oswald',
    'Raleway',
    'Poppins',
    'Merriweather',
    'Playfair Display',
    'Source Sans Pro',
    'Ubuntu',
    'Nunito',
  ];

  @override
  RenderFontPicker createRenderObject(BuildContext context) {
    return RenderFontPicker(
      selectedFont: selectedFont,
      onChanged: onChanged,
      fonts: fonts,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderFontPicker renderObject) {
    renderObject
      ..selectedFont = selectedFont
      ..onChanged = onChanged
      ..fonts = fonts;
  }
}

class RenderFontPicker extends RenderBox {
  RenderFontPicker({
    String? selectedFont,
    void Function(String fontFamily)? onChanged,
    required List<String> fonts,
  }) : _selectedFont = selectedFont,
       _onChanged = onChanged,
       _fonts = fonts {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  String? _selectedFont;
  set selectedFont(String? value) {
    _selectedFont = value;
    markNeedsPaint();
  }

  void Function(String fontFamily)? _onChanged;
  set onChanged(void Function(String fontFamily)? value) => _onChanged = value;

  List<String> _fonts;
  set fonts(List<String> value) {
    _fonts = value;
    markNeedsLayout();
  }

  late TapGestureRecognizer _tap;
  bool _isOpen = false;
  int? _hoveredIndex;

  static const double _buttonHeight = 44.0;
  static const double _itemHeight = 44.0;

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
      for (int i = 0; i < _fonts.length; i++) {
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

    // Selected value with font preview
    textPainter.text = TextSpan(
      text: _selectedFont ?? 'Select font...',
      style: TextStyle(
        fontSize: 14,
        fontFamily: _selectedFont,
        color: _selectedFont != null
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
        _fonts.length * _itemHeight,
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

      for (int i = 0; i < _fonts.length; i++) {
        if (i >= _itemRects.length) break;
        final itemRect = _itemRects[i].shift(offset);
        final font = _fonts[i];
        final isSelected = _selectedFont == font;
        final isHovered = _hoveredIndex == i;

        if (isSelected) {
          canvas.drawRect(itemRect, Paint()..color = const Color(0xFFE3F2FD));
        } else if (isHovered) {
          canvas.drawRect(itemRect, Paint()..color = const Color(0xFFF5F5F5));
        }

        // Font preview
        textPainter.text = TextSpan(
          text: font,
          style: TextStyle(
            fontSize: 14,
            fontFamily: font,
            color: isSelected
                ? const Color(0xFF2196F3)
                : const Color(0xFF333333),
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

        // Sample text
        textPainter.text = TextSpan(
          text: 'Aa',
          style: TextStyle(
            fontSize: 18,
            fontFamily: font,
            color: const Color(0xFF999999),
          ),
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
          _selectedFont = _fonts[i];
          _isOpen = false;
          _onChanged?.call(_fonts[i]);
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
