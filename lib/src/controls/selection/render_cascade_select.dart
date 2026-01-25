// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'cascade_option.dart';


class RenderCascadeSelect<T> extends RenderBox {
  RenderCascadeSelect({
    required String placeholder,
    required List<T> selectedPath,
    required List<CascadeOption<T>> options,
  }) : _placeholder = placeholder,
       _selectedPath = selectedPath,
       _options = options {
    _tap = TapGestureRecognizer()..onTap = () => onTap?.call();
  }

  String _placeholder;
  set placeholder(String val) {
    if (_placeholder != val) {
      _placeholder = val;
      markNeedsPaint();
    }
  }

  List<T> _selectedPath;
  set selectedPath(List<T> val) {
    if (_selectedPath != val) {
      _selectedPath = val;
      markNeedsPaint();
    }
  }

  List<CascadeOption<T>> _options;
  set options(List<CascadeOption<T>> val) {
    _options = val;
    markNeedsPaint();
  }

  LayerLink? layerLink;
  VoidCallback? onTap;
  late TapGestureRecognizer _tap;

  @override
  void performLayout() {
    size = constraints.constrain(const Size(double.infinity, 44));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Rect rect = offset & size;
    final Paint bg = Paint()..color = const Color(0xFFFFFFFF);
    final Paint border = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    context.canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      bg,
    );
    context.canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      border,
    );

    String text = _placeholder;
    bool isEmpty = _selectedPath.isEmpty;

    if (!isEmpty) {
      List<String> labels = [];
      List<CascadeOption<T>> current = _options;
      for (var val in _selectedPath) {
        var found = current.where((o) => o.value == val);
        if (found.isNotEmpty) {
          labels.add(found.first.label);
          current = found.first.hasChildren ? found.first.children : [];
        }
      }
      text = labels.join(' / ');
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: isEmpty ? const Color(0xFF999999) : const Color(0xFF000000),
          fontSize: 14,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      context.canvas,
      offset + Offset(12, (size.height - textPainter.height) / 2),
    );

    final double arrowX = offset.dx + size.width - 16;
    final double arrowY = offset.dy + size.height / 2;
    final Paint arrowPaint = Paint()
      ..color = const Color(0xFF757575)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final Path path = Path();
    path.moveTo(arrowX - 4, arrowY - 2);
    path.lineTo(arrowX, arrowY + 2);
    path.lineTo(arrowX + 4, arrowY - 2);
    context.canvas.drawPath(path, arrowPaint);

    if (layerLink != null) {
      context.pushLayer(
        LeaderLayer(link: layerLink!, offset: Offset.zero),
        (c, o) {},
        offset,
      );
    }
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _tap.addPointer(event);
    }
  }

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }
}
