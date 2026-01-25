import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

/// A music notation input widget.
class MusicNotationInput extends LeafRenderObjectWidget {
  const MusicNotationInput({
    super.key,
    this.notes = const [],
    this.onChanged,
    this.showKeyboard = true,
    this.tag,
  });

  final List<String> notes;
  final void Function(List<String> notes)? onChanged;
  final bool showKeyboard;
  final String? tag;

  @override
  RenderMusicNotationInput createRenderObject(BuildContext context) {
    return RenderMusicNotationInput(
      notes: notes,
      onChanged: onChanged,
      showKeyboard: showKeyboard,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderMusicNotationInput renderObject,
  ) {
    renderObject
      ..notes = notes
      ..onChanged = onChanged
      ..showKeyboard = showKeyboard;
  }
}

class RenderMusicNotationInput extends RenderBox {
  RenderMusicNotationInput({
    required List<String> notes,
    void Function(List<String> notes)? onChanged,
    required bool showKeyboard,
  }) : _notes = List.from(notes),
       _onChanged = onChanged,
       _showKeyboard = showKeyboard {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  List<String> _notes;
  set notes(List<String> value) {
    _notes = List.from(value);
    markNeedsPaint();
  }

  void Function(List<String> notes)? _onChanged;
  set onChanged(void Function(List<String> notes)? value) => _onChanged = value;

  bool _showKeyboard;
  set showKeyboard(bool value) {
    if (_showKeyboard != value) {
      _showKeyboard = value;
      markNeedsLayout();
    }
  }

  late TapGestureRecognizer _tap;
  int? _hoveredKey;

  static const _noteNames = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];
  static const _blackKeys = ['C#', 'D#', 'F#', 'G#', 'A#'];

  static const double _staffHeight = 100.0;
  static const double _keyboardHeight = 80.0;
  static const double _whiteKeyWidth = 40.0;
  static const double _blackKeyWidth = 24.0;

  final List<Rect> _whiteKeyRects = [];
  final List<Rect> _blackKeyRects = [];
  Rect _clearRect = Rect.zero;

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    _whiteKeyRects.clear();
    _blackKeyRects.clear();

    final keyboardSpace = _showKeyboard ? _keyboardHeight + 50 : 0.0;
    size = constraints.constrain(
      Size(constraints.maxWidth, _staffHeight + keyboardSpace),
    );

    if (_showKeyboard) {
      final startX = (size.width - 7 * _whiteKeyWidth) / 2;

      // White keys
      for (int i = 0; i < 7; i++) {
        _whiteKeyRects.add(
          Rect.fromLTWH(
            startX + i * _whiteKeyWidth,
            _staffHeight + 8,
            _whiteKeyWidth - 2,
            _keyboardHeight,
          ),
        );
      }

      // Black keys (between white keys, except E-F and B-C)
      final blackPositions = [0, 1, 3, 4, 5]; // C#, D#, F#, G#, A#
      for (int i = 0; i < blackPositions.length; i++) {
        final pos = blackPositions[i];
        _blackKeyRects.add(
          Rect.fromLTWH(
            startX + pos * _whiteKeyWidth + _whiteKeyWidth - _blackKeyWidth / 2,
            _staffHeight + 8,
            _blackKeyWidth,
            _keyboardHeight * 0.6,
          ),
        );
      }

      _clearRect = Rect.fromLTWH(
        size.width - 80,
        _staffHeight + _keyboardHeight + 16,
        72,
        32,
      );
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Staff background
    final staffRect = Rect.fromLTWH(
      offset.dx,
      offset.dy,
      size.width,
      _staffHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(staffRect, const Radius.circular(8)),
      Paint()..color = const Color(0xFFFFFFF0),
    );

    // Staff lines
    final linePaint = Paint()
      ..color = const Color(0xFF333333)
      ..strokeWidth = 1;
    for (int i = 0; i < 5; i++) {
      final y = offset.dy + 30 + i * 10;
      canvas.drawLine(
        Offset(offset.dx + 20, y),
        Offset(offset.dx + size.width - 20, y),
        linePaint,
      );
    }

    // Treble clef
    textPainter.text = const TextSpan(
      text: '𝄞',
      style: TextStyle(fontSize: 50, color: Color(0xFF333333)),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(offset.dx + 24, offset.dy + 20));

    // Notes
    final noteStartX = offset.dx + 80;
    final noteSpacing = 40.0;
    for (int i = 0; i < _notes.length && i < 10; i++) {
      final note = _notes[i];
      final noteIndex = _noteNames.indexOf(note.replaceAll('#', ''));
      if (noteIndex < 0) continue;

      final x = noteStartX + i * noteSpacing;
      final y = offset.dy + 70 - noteIndex * 5;

      // Note head
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 12, height: 10),
        Paint()..color = const Color(0xFF333333),
      );

      // Stem
      canvas.drawLine(
        Offset(x + 5, y),
        Offset(x + 5, y - 30),
        Paint()
          ..color = const Color(0xFF333333)
          ..strokeWidth = 1.5,
      );

      // Sharp indicator
      if (note.contains('#')) {
        textPainter.text = const TextSpan(
          text: '♯',
          style: TextStyle(fontSize: 14, color: Color(0xFF333333)),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x - 16, y - 8));
      }
    }

    if (_showKeyboard) {
      // White keys
      for (int i = 0; i < _whiteKeyRects.length; i++) {
        final rect = _whiteKeyRects[i].shift(offset);
        final isHovered = _hoveredKey == i;

        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          Paint()
            ..color = isHovered
                ? const Color(0xFFE3F2FD)
                : const Color(0xFFFFFFFF),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          Paint()
            ..style = PaintingStyle.stroke
            ..color = const Color(0xFF333333),
        );

        textPainter.text = TextSpan(
          text: _noteNames[i],
          style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(rect.center.dx - textPainter.width / 2, rect.bottom - 20),
        );
      }

      // Black keys
      for (int i = 0; i < _blackKeyRects.length; i++) {
        final rect = _blackKeyRects[i].shift(offset);
        final isHovered = _hoveredKey == 100 + i;

        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          Paint()
            ..color = isHovered
                ? const Color(0xFF424242)
                : const Color(0xFF1A1A1A),
        );
      }

      // Clear button
      final clearRect = _clearRect.shift(offset);
      canvas.drawRRect(
        RRect.fromRectAndRadius(clearRect, const Radius.circular(4)),
        Paint()
          ..color = _hoveredKey == 200
              ? const Color(0xFFE53935)
              : const Color(0xFFF44336),
      );
      textPainter.text = const TextSpan(
        text: 'Clear',
        style: TextStyle(fontSize: 13, color: Color(0xFFFFFFFF)),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        clearRect.center -
            Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  void _handleTapUp(TapUpDetails details) {
    final local = details.localPosition;

    // Check black keys first (they're on top)
    for (int i = 0; i < _blackKeyRects.length; i++) {
      if (_blackKeyRects[i].contains(local)) {
        _notes.add(_blackKeys[i]);
        _onChanged?.call(_notes);
        markNeedsPaint();
        return;
      }
    }

    // Check white keys
    for (int i = 0; i < _whiteKeyRects.length; i++) {
      if (_whiteKeyRects[i].contains(local)) {
        _notes.add(_noteNames[i]);
        _onChanged?.call(_notes);
        markNeedsPaint();
        return;
      }
    }

    // Check clear
    if (_clearRect.contains(local)) {
      _notes.clear();
      _onChanged?.call(_notes);
      markNeedsPaint();
    }
  }

  void _handleHover(PointerHoverEvent event) {
    final local = event.localPosition;
    int? hovered;

    for (int i = 0; i < _blackKeyRects.length; i++) {
      if (_blackKeyRects[i].contains(local)) {
        hovered = 100 + i;
        break;
      }
    }
    if (hovered == null) {
      for (int i = 0; i < _whiteKeyRects.length; i++) {
        if (_whiteKeyRects[i].contains(local)) {
          hovered = i;
          break;
        }
      }
    }
    if (_clearRect.contains(local)) hovered = 200;

    if (_hoveredKey != hovered) {
      _hoveredKey = hovered;
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
