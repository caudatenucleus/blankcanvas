import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

/// Common emoji categories.
enum EmojiCategory {
  smileys,
  animals,
  food,
  activities,
  travel,
  objects,
  symbols,
  flags,
}

/// An emoji picker widget.
class EmojiPicker extends LeafRenderObjectWidget {
  const EmojiPicker({
    super.key,
    required this.onEmojiSelected,
    this.height = 250,
    this.tag,
  });

  final void Function(String emoji) onEmojiSelected;
  final double height;
  final String? tag;

  @override
  RenderEmojiPicker createRenderObject(BuildContext context) {
    return RenderEmojiPicker(
      onEmojiSelected: onEmojiSelected,
      pickerHeight: height,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderEmojiPicker renderObject,
  ) {
    renderObject
      ..onEmojiSelected = onEmojiSelected
      ..pickerHeight = height;
  }
}

class RenderEmojiPicker extends RenderBox {
  RenderEmojiPicker({
    required void Function(String emoji) onEmojiSelected,
    required double pickerHeight,
  }) : _onEmojiSelected = onEmojiSelected,
       _pickerHeight = pickerHeight {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  void Function(String emoji) _onEmojiSelected;
  set onEmojiSelected(void Function(String emoji) value) =>
      _onEmojiSelected = value;

  double _pickerHeight;
  set pickerHeight(double value) {
    if (_pickerHeight != value) {
      _pickerHeight = value;
      markNeedsLayout();
    }
  }

  late TapGestureRecognizer _tap;
  EmojiCategory _selectedCategory = EmojiCategory.smileys;
  int? _hoveredEmoji;
  int? _hoveredCategory;

  static const double _tabHeight = 36.0;
  static const double _emojiSize = 32.0;
  static const int _columns = 8;

  static const Map<EmojiCategory, List<String>> _emojis = {
    EmojiCategory.smileys: [
      '😀',
      '😁',
      '😂',
      '🤣',
      '😃',
      '😄',
      '😅',
      '😆',
      '😉',
      '😊',
      '😋',
      '😎',
      '😍',
      '🥰',
      '😘',
      '😗',
    ],
    EmojiCategory.animals: [
      '🐶',
      '🐱',
      '🐭',
      '🐹',
      '🐰',
      '🦊',
      '🐻',
      '🐼',
      '🐨',
      '🐯',
      '🦁',
      '🐮',
      '🐷',
      '🐸',
      '🐵',
      '🙈',
    ],
    EmojiCategory.food: [
      '🍏',
      '🍎',
      '🍐',
      '🍊',
      '🍋',
      '🍌',
      '🍉',
      '🍇',
      '🍓',
      '🫐',
      '🍈',
      '🍒',
      '🍑',
      '🥭',
      '🍍',
      '🥥',
    ],
    EmojiCategory.activities: [
      '⚽',
      '🏀',
      '🏈',
      '⚾',
      '🥎',
      '🎾',
      '🏐',
      '🏉',
      '🥏',
      '🎱',
      '🏓',
      '🏸',
      '🏒',
      '🏑',
      '🥍',
      '🏏',
    ],
    EmojiCategory.travel: [
      '🚗',
      '🚕',
      '🚙',
      '🚌',
      '🚎',
      '🏎️',
      '🚓',
      '🚑',
      '🚒',
      '🚐',
      '🛻',
      '🚚',
      '🚛',
      '🚜',
      '🛴',
      '🚲',
    ],
    EmojiCategory.objects: [
      '⌚',
      '📱',
      '📲',
      '💻',
      '⌨️',
      '🖥️',
      '🖨️',
      '🖱️',
      '🖲️',
      '🕹️',
      '💽',
      '💾',
      '💿',
      '📀',
      '📷',
      '📸',
    ],
    EmojiCategory.symbols: [
      '❤️',
      '🧡',
      '💛',
      '💚',
      '💙',
      '💜',
      '🖤',
      '🤍',
      '🤎',
      '💔',
      '❣️',
      '💕',
      '💞',
      '💓',
      '💗',
      '💖',
    ],
    EmojiCategory.flags: [
      '🏁',
      '🚩',
      '🎌',
      '🏴',
      '🏳️',
      '🇺🇸',
      '🇬🇧',
      '🇨🇦',
      '🇦🇺',
      '🇩🇪',
      '🇫🇷',
      '🇮🇹',
      '🇯🇵',
      '🇰🇷',
      '🇨🇳',
      '🇮🇳',
    ],
  };

  static const Map<EmojiCategory, String> _categoryIcons = {
    EmojiCategory.smileys: '😀',
    EmojiCategory.animals: '🐶',
    EmojiCategory.food: '🍎',
    EmojiCategory.activities: '⚽',
    EmojiCategory.travel: '🚗',
    EmojiCategory.objects: '💡',
    EmojiCategory.symbols: '❤️',
    EmojiCategory.flags: '🏁',
  };

  final List<Rect> _categoryRects = [];
  final List<Rect> _emojiRects = [];

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    size = constraints.constrain(Size(constraints.maxWidth, _pickerHeight));

    // Category tabs
    _categoryRects.clear();
    final tabWidth = size.width / EmojiCategory.values.length;
    for (int i = 0; i < EmojiCategory.values.length; i++) {
      _categoryRects.add(Rect.fromLTWH(i * tabWidth, 0, tabWidth, _tabHeight));
    }

    // Emoji grid
    _emojiRects.clear();
    final emojis = _emojis[_selectedCategory] ?? [];
    final cellWidth = size.width / _columns;
    for (int i = 0; i < emojis.length; i++) {
      final row = i ~/ _columns;
      final col = i % _columns;
      _emojiRects.add(
        Rect.fromLTWH(
          col * cellWidth,
          _tabHeight + row * _emojiSize,
          cellWidth,
          _emojiSize,
        ),
      );
    }
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

    // Tab bar background
    canvas.drawRect(
      Rect.fromLTWH(offset.dx, offset.dy, size.width, _tabHeight),
      Paint()..color = const Color(0xFFF5F5F5),
    );
    canvas.drawLine(
      Offset(offset.dx, offset.dy + _tabHeight),
      Offset(offset.dx + size.width, offset.dy + _tabHeight),
      Paint()..color = const Color(0xFFE0E0E0),
    );

    // Category tabs
    for (int i = 0; i < EmojiCategory.values.length; i++) {
      final cat = EmojiCategory.values[i];
      final rect = _categoryRects[i].shift(offset);
      final isSelected = cat == _selectedCategory;
      final isHovered = i == _hoveredCategory;

      if (isSelected) {
        canvas.drawLine(
          Offset(rect.left, rect.bottom - 2),
          Offset(rect.right, rect.bottom - 2),
          Paint()
            ..color = const Color(0xFF2196F3)
            ..strokeWidth = 2,
        );
      } else if (isHovered) {
        canvas.drawRect(rect, Paint()..color = const Color(0xFFEEEEEE));
      }

      textPainter.text = TextSpan(
        text: _categoryIcons[cat],
        style: const TextStyle(fontSize: 18),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        rect.center - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }

    // Emoji grid
    final emojis = _emojis[_selectedCategory] ?? [];
    for (int i = 0; i < emojis.length; i++) {
      if (i >= _emojiRects.length) break;
      final rect = _emojiRects[i].shift(offset);
      final isHovered = i == _hoveredEmoji;

      if (isHovered) {
        canvas.drawRect(rect, Paint()..color = const Color(0xFFE3F2FD));
      }

      textPainter.text = TextSpan(
        text: emojis[i],
        style: const TextStyle(fontSize: 24),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        rect.center - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  void _handleTapUp(TapUpDetails details) {
    final local = details.localPosition;

    // Check category tap
    for (int i = 0; i < _categoryRects.length; i++) {
      if (_categoryRects[i].contains(local)) {
        _selectedCategory = EmojiCategory.values[i];
        markNeedsLayout();
        markNeedsPaint();
        return;
      }
    }

    // Check emoji tap
    final emojis = _emojis[_selectedCategory] ?? [];
    for (int i = 0; i < _emojiRects.length; i++) {
      if (_emojiRects[i].contains(local)) {
        _onEmojiSelected(emojis[i]);
        return;
      }
    }
  }

  void _handleHover(PointerHoverEvent event) {
    final local = event.localPosition;
    int? newHoveredCat;
    int? newHoveredEmoji;

    for (int i = 0; i < _categoryRects.length; i++) {
      if (_categoryRects[i].contains(local)) {
        newHoveredCat = i;
        break;
      }
    }

    for (int i = 0; i < _emojiRects.length; i++) {
      if (_emojiRects[i].contains(local)) {
        newHoveredEmoji = i;
        break;
      }
    }

    if (_hoveredCategory != newHoveredCat || _hoveredEmoji != newHoveredEmoji) {
      _hoveredCategory = newHoveredCat;
      _hoveredEmoji = newHoveredEmoji;
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
