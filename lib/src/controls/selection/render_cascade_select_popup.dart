// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;
import 'cascade_option.dart';


class RenderCascadeSelectPopup<T> extends RenderBox {
  RenderCascadeSelectPopup({
    required List<List<CascadeOption<T>>> columns,
    required List<T> selectedPath,
    required void Function(int, CascadeOption<T>) onSelect,
  }) : _columns = columns,
       _selectedPath = selectedPath,
       _onSelect = onSelect {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
    _drag = PanGestureRecognizer()..onUpdate = _handleDragUpdate;
  }

  List<List<CascadeOption<T>>> _columns;
  set columns(List<List<CascadeOption<T>>> val) {
    if (_columns != val) {
      _columns = val;
      _updateScrollOffsets();
      markNeedsLayout();
    }
  }

  List<T> _selectedPath;
  set selectedPath(List<T> val) {
    if (_selectedPath != val) {
      _selectedPath = val;
      markNeedsPaint();
    }
  }

  void Function(int, CascadeOption<T>) _onSelect;
  set onSelect(void Function(int, CascadeOption<T>) val) => _onSelect = val;

  late TapGestureRecognizer _tap;
  late PanGestureRecognizer _drag;

  List<double> _scrollOffsets = [];

  void _updateScrollOffsets() {
    if (_scrollOffsets.length < _columns.length) {
      _scrollOffsets.addAll(
        List.filled(_columns.length - _scrollOffsets.length, 0.0),
      );
    } else if (_scrollOffsets.length > _columns.length) {
      _scrollOffsets = _scrollOffsets.sublist(0, _columns.length);
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _updateScrollOffsets();
  }

  static const double _colWidth = 150.0;
  static const double _itemHeight = 40.0;
  static const double _maxHeight = 250.0;

  @override
  void performLayout() {
    double width = _columns.length * _colWidth;
    size = Size(width, _maxHeight);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    // Bg
    canvas.drawRect(offset & size, Paint()..color = const Color(0xFFFFFFFF));
    canvas.drawShadow(
      Path()..addRect(offset & size),
      const Color(0x33000000),
      4,
      true,
    );

    // Columns
    for (int i = 0; i < _columns.length; i++) {
      _paintColumn(context, offset, i);
    }

    // Borders
    final borderPaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    // vertical separators
    for (int i = 1; i < _columns.length; i++) {
      double x = offset.dx + i * _colWidth;
      canvas.drawLine(
        Offset(x, offset.dy),
        Offset(x, offset.dy + size.height),
        borderPaint,
      );
    }
    // Outer border
    canvas.drawRect(offset & size, borderPaint);
  }

  void _paintColumn(PaintingContext context, Offset baseOffset, int colIndex) {
    final column = _columns[colIndex];
    final double scrollY = _scrollOffsets[colIndex];

    final double colX = baseOffset.dx + colIndex * _colWidth;
    final double colY = baseOffset.dy;

    context.pushClipRect(
      needsCompositing,
      baseOffset,
      Rect.fromLTWH(colIndex * _colWidth, 0, _colWidth, size.height),
      (ctx, offset) {
        for (int j = 0; j < column.length; j++) {
          final item = column[j];
          final double itemY = j * _itemHeight - scrollY;

          if (itemY + _itemHeight < 0 || itemY > size.height) continue;

          bool isSelected =
              colIndex < _selectedPath.length &&
              _selectedPath[colIndex] == item.value;
          if (isSelected) {
            ctx.canvas.drawRect(
              Rect.fromLTWH(colX, colY + itemY, _colWidth, _itemHeight),
              Paint()..color = const Color(0xFFE3F2FD),
            );
          }

          final tp = TextPainter(
            text: TextSpan(
              text: item.label,
              style: const TextStyle(fontSize: 14, color: Color(0xFF000000)),
            ),
            textDirection: TextDirection.ltr,
            maxLines: 1,
            ellipsis: '...',
          )..layout(maxWidth: _colWidth - 24);

          tp.paint(
            ctx.canvas,
            Offset(colX + 12, colY + itemY + (_itemHeight - tp.height) / 2),
          );

          if (item.hasChildren) {
            final double cx = colX + _colWidth - 16;
            final double cy = colY + itemY + _itemHeight / 2;
            final cPaint = Paint()
              ..color = const Color(0xFF999999)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5;
            final Path p = Path();
            p.moveTo(cx - 3, cy - 3);
            p.lineTo(cx + 1, cy);
            p.lineTo(cx - 3, cy + 3);
            ctx.canvas.drawPath(p, cPaint);
          }
        }
      },
    );
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final colIndex = (details.localPosition.dx / _colWidth).floor();
    if (colIndex >= 0 && colIndex < _columns.length) {
      _scrollOffsets[colIndex] -= details.delta.dy;

      final contentHeight = _columns[colIndex].length * _itemHeight;
      final minScroll = 0.0;
      final maxScroll = math.max(0.0, contentHeight - size.height);

      if (_scrollOffsets[colIndex] < minScroll) {
        _scrollOffsets[colIndex] = minScroll;
      }
      if (_scrollOffsets[colIndex] > maxScroll) {
        _scrollOffsets[colIndex] = maxScroll;
      }

      markNeedsPaint();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    final colIndex = (details.localPosition.dx / _colWidth).floor();
    if (colIndex >= 0 && colIndex < _columns.length) {
      final double scrollY = _scrollOffsets[colIndex];
      final double yInContent = details.localPosition.dy + scrollY;
      final int itemIndex = (yInContent / _itemHeight).floor();

      if (itemIndex >= 0 && itemIndex < _columns[colIndex].length) {
        _onSelect(colIndex, _columns[colIndex][itemIndex]);
      }
    }
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _tap.addPointer(event);
      _drag.addPointer(event);
    }
  }

  @override
  void detach() {
    _tap.dispose();
    _drag.dispose();
    super.detach();
  }
}
