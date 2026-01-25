import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

/// A chemistry input widget for entering chemical formulas.
class ChemistryInput extends LeafRenderObjectWidget {
  const ChemistryInput({
    super.key,
    this.formula = '',
    this.onChanged,
    this.showKeypad = true,
    this.tag,
  });

  final String formula;
  final void Function(String formula)? onChanged;
  final bool showKeypad;
  final String? tag;

  @override
  RenderChemistryInput createRenderObject(BuildContext context) {
    return RenderChemistryInput(
      formula: formula,
      onChanged: onChanged,
      showKeypad: showKeypad,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderChemistryInput renderObject,
  ) {
    renderObject
      ..formula = formula
      ..onChanged = onChanged
      ..showKeypad = showKeypad;
  }
}

class RenderChemistryInput extends RenderBox {
  RenderChemistryInput({
    required String formula,
    void Function(String formula)? onChanged,
    required bool showKeypad,
  }) : _formula = formula,
       _onChanged = onChanged,
       _showKeypad = showKeypad {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  String _formula;
  set formula(String value) {
    if (_formula != value) {
      _formula = value;
      markNeedsPaint();
    }
  }

  void Function(String formula)? _onChanged;
  set onChanged(void Function(String formula)? value) => _onChanged = value;

  bool _showKeypad;
  set showKeypad(bool value) {
    if (_showKeypad != value) {
      _showKeypad = value;
      markNeedsLayout();
    }
  }

  late TapGestureRecognizer _tap;
  int? _hoveredButton;
  int _activeTab = 0; // 0: Common, 1: Elements, 2: Bonds

  static const _commonSymbols = [
    'H',
    'O',
    'C',
    'N',
    'S',
    'P',
    'Cl',
    'Na',
    'K',
    'Ca',
    'Fe',
    'Mg',
  ];
  static const _subscripts = ['₀', '₁', '₂', '₃', '₄', '₅', '₆', '₇', '₈', '₉'];
  static const _bonds = ['→', '⇌', '+', '−', '·', '↑', '↓', '(', ')', ':'];

  static const double _displayHeight = 60.0;
  static const double _tabHeight = 36.0;
  static const double _buttonSize = 44.0;
  static const double _buttonSpacing = 4.0;
  static const int _columns = 6;

  final List<Rect> _buttonRects = [];
  final List<Rect> _tabRects = [];
  Rect _backspaceRect = Rect.zero;
  Rect _clearRect = Rect.zero;

  List<String> get _currentSymbols {
    switch (_activeTab) {
      case 0:
        return _commonSymbols;
      case 1:
        return _subscripts;
      case 2:
        return _bonds;
      default:
        return _commonSymbols;
    }
  }

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    _buttonRects.clear();
    _tabRects.clear();

    final rows = (_currentSymbols.length / _columns).ceil();
    final keypadHeight = _showKeypad
        ? _tabHeight + rows * (_buttonSize + _buttonSpacing) + 8
        : 0.0;
    size = constraints.constrain(
      Size(constraints.maxWidth, _displayHeight + keypadHeight + 50),
    );

    if (_showKeypad) {
      // Tabs
      final tabWidth = size.width / 3;
      for (int i = 0; i < 3; i++) {
        _tabRects.add(
          Rect.fromLTWH(i * tabWidth, _displayHeight + 8, tabWidth, _tabHeight),
        );
      }

      // Buttons
      final buttonWidth =
          (size.width - (_columns - 1) * _buttonSpacing) / _columns;
      final startY = _displayHeight + _tabHeight + 16;
      for (int i = 0; i < _currentSymbols.length; i++) {
        final row = i ~/ _columns;
        final col = i % _columns;
        _buttonRects.add(
          Rect.fromLTWH(
            col * (buttonWidth + _buttonSpacing),
            startY + row * (_buttonSize + _buttonSpacing),
            buttonWidth,
            _buttonSize,
          ),
        );
      }

      // Control buttons
      final controlY = startY + rows * (_buttonSize + _buttonSpacing);
      _backspaceRect = Rect.fromLTWH(0, controlY, size.width / 2 - 2, 40);
      _clearRect = Rect.fromLTWH(
        size.width / 2 + 2,
        controlY,
        size.width / 2 - 2,
        40,
      );
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Display area
    final displayRect = Rect.fromLTWH(
      offset.dx,
      offset.dy,
      size.width,
      _displayHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(displayRect, const Radius.circular(8)),
      Paint()..color = const Color(0xFF263238),
    );

    // Formula with proper rendering
    textPainter.text = TextSpan(
      text: _formula.isEmpty ? 'Enter formula...' : _formula,
      style: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w400,
        color: _formula.isEmpty
            ? const Color(0xFF78909C)
            : const Color(0xFFFFFFFF),
      ),
    );
    textPainter.layout(maxWidth: size.width - 24);
    textPainter.paint(
      canvas,
      Offset(
        displayRect.left + 12,
        displayRect.center.dy - textPainter.height / 2,
      ),
    );

    if (_showKeypad) {
      // Tabs
      final tabLabels = ['Common', 'Subscript', 'Bonds'];
      for (int i = 0; i < _tabRects.length; i++) {
        final rect = _tabRects[i].shift(offset);
        final isActive = _activeTab == i;

        canvas.drawRect(
          rect,
          Paint()
            ..color = isActive
                ? const Color(0xFF4CAF50)
                : const Color(0xFFE0E0E0),
        );
        if (isActive) {
          canvas.drawRect(
            Rect.fromLTWH(rect.left, rect.bottom - 3, rect.width, 3),
            Paint()..color = const Color(0xFF2E7D32),
          );
        }

        textPainter.text = TextSpan(
          text: tabLabels[i],
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isActive ? const Color(0xFFFFFFFF) : const Color(0xFF666666),
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          rect.center - Offset(textPainter.width / 2, textPainter.height / 2),
        );
      }

      // Symbol buttons
      for (int i = 0; i < _buttonRects.length; i++) {
        if (i >= _currentSymbols.length) break;
        final rect = _buttonRects[i].shift(offset);
        final symbol = _currentSymbols[i];
        final isHovered = _hoveredButton == i;

        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(6)),
          Paint()
            ..color = isHovered
                ? const Color(0xFF4CAF50)
                : const Color(0xFFFFFFFF),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(6)),
          Paint()
            ..style = PaintingStyle.stroke
            ..color = const Color(0xFFE0E0E0),
        );

        textPainter.text = TextSpan(
          text: symbol,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isHovered
                ? const Color(0xFFFFFFFF)
                : const Color(0xFF333333),
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          rect.center - Offset(textPainter.width / 2, textPainter.height / 2),
        );
      }

      // Control buttons
      _drawControlButton(
        canvas,
        _backspaceRect.shift(offset),
        '← Backspace',
        const Color(0xFFFF9800),
        _hoveredButton == 100,
      );
      _drawControlButton(
        canvas,
        _clearRect.shift(offset),
        'Clear',
        const Color(0xFFF44336),
        _hoveredButton == 101,
      );
    }
  }

  void _drawControlButton(
    Canvas canvas,
    Rect rect,
    String text,
    Color color,
    bool isHovered,
  ) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      Paint()..color = isHovered ? color : color.withValues(alpha: 0.85),
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontSize: 14, color: Color(0xFFFFFFFF)),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      rect.center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  void _handleTapUp(TapUpDetails details) {
    final local = details.localPosition;

    // Check tabs
    for (int i = 0; i < _tabRects.length; i++) {
      if (_tabRects[i].contains(local)) {
        _activeTab = i;
        markNeedsLayout();
        return;
      }
    }

    // Check symbol buttons
    for (int i = 0; i < _buttonRects.length; i++) {
      if (_buttonRects[i].contains(local) && i < _currentSymbols.length) {
        _formula += _currentSymbols[i];
        _onChanged?.call(_formula);
        markNeedsPaint();
        return;
      }
    }

    // Check control buttons
    if (_backspaceRect.contains(local)) {
      if (_formula.isNotEmpty) {
        _formula = _formula.substring(0, _formula.length - 1);
        _onChanged?.call(_formula);
        markNeedsPaint();
      }
    } else if (_clearRect.contains(local)) {
      _formula = '';
      _onChanged?.call(_formula);
      markNeedsPaint();
    }
  }

  void _handleHover(PointerHoverEvent event) {
    final local = event.localPosition;
    int? hovered;

    for (int i = 0; i < _buttonRects.length; i++) {
      if (_buttonRects[i].contains(local)) {
        hovered = i;
        break;
      }
    }
    if (_backspaceRect.contains(local)) hovered = 100;
    if (_clearRect.contains(local)) hovered = 101;

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
