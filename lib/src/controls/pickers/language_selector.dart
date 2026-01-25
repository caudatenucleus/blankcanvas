import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

/// Language data with code and name.
class Language {
  const Language({required this.code, required this.name, this.nativeName});
  final String code;
  final String name;
  final String? nativeName;
}

/// A language selector dropdown.
class LanguageSelector extends LeafRenderObjectWidget {
  const LanguageSelector({
    super.key,
    this.selectedLanguage,
    this.onChanged,
    this.languages = defaultLanguages,
    this.tag,
  });

  final Language? selectedLanguage;
  final void Function(Language language)? onChanged;
  final List<Language> languages;
  final String? tag;

  static const List<Language> defaultLanguages = [
    Language(code: 'en', name: 'English', nativeName: 'English'),
    Language(code: 'es', name: 'Spanish', nativeName: 'Español'),
    Language(code: 'fr', name: 'French', nativeName: 'Français'),
    Language(code: 'de', name: 'German', nativeName: 'Deutsch'),
    Language(code: 'it', name: 'Italian', nativeName: 'Italiano'),
    Language(code: 'pt', name: 'Portuguese', nativeName: 'Português'),
    Language(code: 'zh', name: 'Chinese', nativeName: '中文'),
    Language(code: 'ja', name: 'Japanese', nativeName: '日本語'),
    Language(code: 'ko', name: 'Korean', nativeName: '한국어'),
    Language(code: 'ar', name: 'Arabic', nativeName: 'العربية'),
    Language(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी'),
    Language(code: 'ru', name: 'Russian', nativeName: 'Русский'),
  ];

  @override
  RenderLanguageSelector createRenderObject(BuildContext context) {
    return RenderLanguageSelector(
      selectedLanguage: selectedLanguage,
      onChanged: onChanged,
      languages: languages,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderLanguageSelector renderObject,
  ) {
    renderObject
      ..selectedLanguage = selectedLanguage
      ..onChanged = onChanged
      ..languages = languages;
  }
}

class RenderLanguageSelector extends RenderBox {
  RenderLanguageSelector({
    Language? selectedLanguage,
    void Function(Language language)? onChanged,
    required List<Language> languages,
  }) : _selectedLanguage = selectedLanguage,
       _onChanged = onChanged,
       _languages = languages {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  Language? _selectedLanguage;
  set selectedLanguage(Language? value) {
    _selectedLanguage = value;
    markNeedsPaint();
  }

  void Function(Language language)? _onChanged;
  set onChanged(void Function(Language language)? value) => _onChanged = value;

  List<Language> _languages;
  set languages(List<Language> value) {
    _languages = value;
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
      for (int i = 0; i < _languages.length; i++) {
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

    // Globe icon
    textPainter.text = const TextSpan(
      text: '🌐',
      style: TextStyle(fontSize: 18),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        offset.dx + 12,
        offset.dy + _buttonRect.center.dy - textPainter.height / 2,
      ),
    );

    // Selected value
    final selected = _selectedLanguage;
    textPainter.text = TextSpan(
      text: selected != null ? selected.name : 'Select language...',
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
        offset.dx + 40,
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
        _languages.length * _itemHeight,
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

      for (int i = 0; i < _languages.length; i++) {
        if (i >= _itemRects.length) break;
        final itemRect = _itemRects[i].shift(offset);
        final lang = _languages[i];
        final isSelected = _selectedLanguage?.code == lang.code;
        final isHovered = _hoveredIndex == i;

        if (isSelected) {
          canvas.drawRect(itemRect, Paint()..color = const Color(0xFFE3F2FD));
        } else if (isHovered) {
          canvas.drawRect(itemRect, Paint()..color = const Color(0xFFF5F5F5));
        }

        textPainter.text = TextSpan(
          text: lang.name,
          style: TextStyle(
            fontSize: 14,
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

        if (lang.nativeName != null) {
          textPainter.text = TextSpan(
            text: lang.nativeName,
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
          _selectedLanguage = _languages[i];
          _isOpen = false;
          _onChanged?.call(_languages[i]);
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
