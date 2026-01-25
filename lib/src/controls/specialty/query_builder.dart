import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

/// A query condition.
class QueryCondition {
  QueryCondition({
    required this.field,
    required this.operator,
    required this.value,
  });
  String field;
  String operator;
  String value;
}

/// A query builder for constructing database-like queries.
class QueryBuilder extends LeafRenderObjectWidget {
  const QueryBuilder({
    super.key,
    this.fields = const ['name', 'email', 'age', 'date'],
    this.onQueryChanged,
    this.tag,
  });

  final List<String> fields;
  final void Function(List<QueryCondition> conditions)? onQueryChanged;
  final String? tag;

  @override
  RenderQueryBuilder createRenderObject(BuildContext context) {
    return RenderQueryBuilder(fields: fields, onQueryChanged: onQueryChanged);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderQueryBuilder renderObject,
  ) {
    renderObject
      ..fields = fields
      ..onQueryChanged = onQueryChanged;
  }
}

class RenderQueryBuilder extends RenderBox {
  RenderQueryBuilder({
    required List<String> fields,
    void Function(List<QueryCondition> conditions)? onQueryChanged,
  }) : _fields = fields,
       _onQueryChanged = onQueryChanged {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
    _conditions.add(
      QueryCondition(field: fields.first, operator: '=', value: ''),
    );
  }

  List<String> _fields;
  set fields(List<String> value) {
    _fields = value;
    markNeedsPaint();
  }

  void Function(List<QueryCondition> conditions)? _onQueryChanged;
  set onQueryChanged(void Function(List<QueryCondition> conditions)? value) =>
      _onQueryChanged = value;

  late TapGestureRecognizer _tap;
  final List<QueryCondition> _conditions = [];
  int? _hoveredButton;

  // ignore: unused_field
  static const List<String> _operators = [
    '=',
    '!=',
    '>',
    '<',
    '>=',
    '<=',
    'contains',
    'starts with',
  ];
  static const double _rowHeight = 48.0;
  static const double _buttonHeight = 36.0;

  final List<Rect> _addButtonRects = [];
  final List<Rect> _removeButtonRects = [];
  Rect _addConditionRect = Rect.zero;

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    _addButtonRects.clear();
    _removeButtonRects.clear();

    final height = _conditions.length * _rowHeight + _buttonHeight + 16;
    size = constraints.constrain(Size(constraints.maxWidth, height));

    for (int i = 0; i < _conditions.length; i++) {
      _removeButtonRects.add(
        Rect.fromLTWH(size.width - 36, i * _rowHeight + 6, 30, 30),
      );
    }
    _addConditionRect = Rect.fromLTWH(
      0,
      _conditions.length * _rowHeight + 8,
      140,
      _buttonHeight,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < _conditions.length; i++) {
      final y = offset.dy + i * _rowHeight;
      final condition = _conditions[i];

      // Row background
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(offset.dx, y, size.width - 40, _rowHeight - 4),
          const Radius.circular(4),
        ),
        Paint()..color = const Color(0xFFF5F5F5),
      );

      // Connector (AND/OR)
      if (i > 0) {
        textPainter.text = const TextSpan(
          text: 'AND',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2196F3),
          ),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(offset.dx + 4, y - 8));
      }

      // Field
      textPainter.text = TextSpan(
        text: condition.field,
        style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(offset.dx + 12, y + _rowHeight / 2 - textPainter.height / 2),
      );

      // Operator
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(offset.dx + 80, y + 8, 80, 28),
          const Radius.circular(4),
        ),
        Paint()..color = const Color(0xFFE0E0E0),
      );
      textPainter.text = TextSpan(
        text: condition.operator,
        style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          offset.dx + 120 - textPainter.width / 2,
          y + _rowHeight / 2 - textPainter.height / 2,
        ),
      );

      // Value
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(offset.dx + 170, y + 8, size.width - 220, 28),
          const Radius.circular(4),
        ),
        Paint()..color = const Color(0xFFFFFFFF),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(offset.dx + 170, y + 8, size.width - 220, 28),
          const Radius.circular(4),
        ),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = const Color(0xFFE0E0E0),
      );
      textPainter.text = TextSpan(
        text: condition.value.isEmpty ? 'value' : condition.value,
        style: TextStyle(
          fontSize: 12,
          color: condition.value.isEmpty
              ? const Color(0xFF999999)
              : const Color(0xFF333333),
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(offset.dx + 178, y + _rowHeight / 2 - textPainter.height / 2),
      );

      // Remove button
      final removeRect = _removeButtonRects[i].shift(offset);
      final isRemoveHovered = _hoveredButton == i + 1000;
      canvas.drawCircle(
        removeRect.center,
        15,
        Paint()
          ..color = isRemoveHovered
              ? const Color(0xFFE53935)
              : const Color(0xFFEEEEEE),
      );
      textPainter.text = TextSpan(
        text: '×',
        style: TextStyle(
          fontSize: 16,
          color: isRemoveHovered
              ? const Color(0xFFFFFFFF)
              : const Color(0xFF999999),
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        removeRect.center -
            Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }

    // Add condition button
    final addRect = _addConditionRect.shift(offset);
    final isAddHovered = _hoveredButton == 0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(addRect, const Radius.circular(4)),
      Paint()
        ..color = isAddHovered
            ? const Color(0xFF2196F3)
            : const Color(0xFFE3F2FD),
    );
    textPainter.text = TextSpan(
      text: '+ Add condition',
      style: TextStyle(
        fontSize: 13,
        color: isAddHovered ? const Color(0xFFFFFFFF) : const Color(0xFF2196F3),
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      addRect.center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  void _handleTapUp(TapUpDetails details) {
    final local = details.localPosition;

    if (_addConditionRect.contains(local)) {
      _conditions.add(
        QueryCondition(field: _fields.first, operator: '=', value: ''),
      );
      _onQueryChanged?.call(_conditions);
      markNeedsLayout();
      return;
    }

    for (int i = 0; i < _removeButtonRects.length; i++) {
      if (_removeButtonRects[i].contains(local) && _conditions.length > 1) {
        _conditions.removeAt(i);
        _onQueryChanged?.call(_conditions);
        markNeedsLayout();
        return;
      }
    }
  }

  void _handleHover(PointerHoverEvent event) {
    final local = event.localPosition;
    int? hovered;

    if (_addConditionRect.contains(local)) {
      hovered = 0;
    } else {
      for (int i = 0; i < _removeButtonRects.length; i++) {
        if (_removeButtonRects[i].contains(local)) {
          hovered = i + 1000;
          break;
        }
      }
    }

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
