import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

/// An icon picker grid.
class IconPicker extends LeafRenderObjectWidget {
  const IconPicker({
    super.key,
    this.selectedIcon,
    this.onChanged,
    this.icons = defaultIcons,
    this.columns = 6,
    this.tag,
  });

  final IconData? selectedIcon;
  final void Function(IconData icon)? onChanged;
  final List<IconData> icons;
  final int columns;
  final String? tag;

  static const List<IconData> defaultIcons = [
    IconData(0xe88a, fontFamily: 'MaterialIcons'), // home
    IconData(0xe7fd, fontFamily: 'MaterialIcons'), // person
    IconData(0xe0be, fontFamily: 'MaterialIcons'), // email
    IconData(0xe0cd, fontFamily: 'MaterialIcons'), // phone
    IconData(0xe8b8, fontFamily: 'MaterialIcons'), // settings
    IconData(0xe8b6, fontFamily: 'MaterialIcons'), // search
    IconData(0xe145, fontFamily: 'MaterialIcons'), // add
    IconData(0xe5cd, fontFamily: 'MaterialIcons'), // close
    IconData(0xe876, fontFamily: 'MaterialIcons'), // check
    IconData(0xe8e5, fontFamily: 'MaterialIcons'), // star
    IconData(0xe87c, fontFamily: 'MaterialIcons'), // favorite
    IconData(0xe2bd, fontFamily: 'MaterialIcons'), // image
    IconData(0xe3b0, fontFamily: 'MaterialIcons'), // camera
    IconData(0xe04a, fontFamily: 'MaterialIcons'), // play
    IconData(0xe03c, fontFamily: 'MaterialIcons'), // music
    IconData(0xe02e, fontFamily: 'MaterialIcons'), // movie
    IconData(0xe8f6, fontFamily: 'MaterialIcons'), // thumb_up
    IconData(0xe8fb, fontFamily: 'MaterialIcons'), // thumb_down
    IconData(0xe87d, fontFamily: 'MaterialIcons'), // share
    IconData(0xe161, fontFamily: 'MaterialIcons'), // send
    IconData(0xe0d0, fontFamily: 'MaterialIcons'), // chat
    IconData(0xe7f0, fontFamily: 'MaterialIcons'), // notifications
    IconData(0xe616, fontFamily: 'MaterialIcons'), // cloud
    IconData(0xe2c6, fontFamily: 'MaterialIcons'), // folder
  ];

  @override
  RenderIconPicker createRenderObject(BuildContext context) {
    return RenderIconPicker(
      selectedIcon: selectedIcon,
      onChanged: onChanged,
      icons: icons,
      columns: columns,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderIconPicker renderObject) {
    renderObject
      ..selectedIcon = selectedIcon
      ..onChanged = onChanged
      ..icons = icons
      ..columns = columns;
  }
}

class RenderIconPicker extends RenderBox {
  RenderIconPicker({
    IconData? selectedIcon,
    void Function(IconData icon)? onChanged,
    required List<IconData> icons,
    required int columns,
  }) : _selectedIcon = selectedIcon,
       _onChanged = onChanged,
       _icons = icons,
       _columns = columns {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  IconData? _selectedIcon;
  set selectedIcon(IconData? value) {
    _selectedIcon = value;
    markNeedsPaint();
  }

  void Function(IconData icon)? _onChanged;
  set onChanged(void Function(IconData icon)? value) => _onChanged = value;

  List<IconData> _icons;
  set icons(List<IconData> value) {
    _icons = value;
    markNeedsLayout();
  }

  int _columns;
  set columns(int value) {
    if (_columns != value) {
      _columns = value;
      markNeedsLayout();
    }
  }

  late TapGestureRecognizer _tap;
  int? _hoveredIndex;

  static const double _cellSize = 44.0;
  static const double _iconSize = 24.0;

  final List<Rect> _iconRects = [];

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    _iconRects.clear();
    final rows = (_icons.length / _columns).ceil();
    size = constraints.constrain(Size(_columns * _cellSize, rows * _cellSize));

    for (int i = 0; i < _icons.length; i++) {
      final row = i ~/ _columns;
      final col = i % _columns;
      _iconRects.add(
        Rect.fromLTWH(col * _cellSize, row * _cellSize, _cellSize, _cellSize),
      );
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Border
    canvas.drawRRect(
      RRect.fromRectAndRadius(offset & size, const Radius.circular(8)),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFFE0E0E0),
    );

    for (int i = 0; i < _icons.length; i++) {
      if (i >= _iconRects.length) break;
      final rect = _iconRects[i].shift(offset);
      final icon = _icons[i];
      final isSelected = _selectedIcon?.codePoint == icon.codePoint;
      final isHovered = _hoveredIndex == i;

      // Background
      if (isSelected) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect.deflate(2), const Radius.circular(6)),
          Paint()..color = const Color(0xFFE3F2FD),
        );
      } else if (isHovered) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect.deflate(2), const Radius.circular(6)),
          Paint()..color = const Color(0xFFF5F5F5),
        );
      }

      // Icon
      textPainter.text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: _iconSize,
          fontFamily: icon.fontFamily,
          color: isSelected ? const Color(0xFF2196F3) : const Color(0xFF666666),
        ),
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
    for (int i = 0; i < _iconRects.length; i++) {
      if (_iconRects[i].contains(local)) {
        _selectedIcon = _icons[i];
        _onChanged?.call(_icons[i]);
        markNeedsPaint();
        return;
      }
    }
  }

  void _handleHover(PointerHoverEvent event) {
    final local = event.localPosition;
    int? hovered;
    for (int i = 0; i < _iconRects.length; i++) {
      if (_iconRects[i].contains(local)) {
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
