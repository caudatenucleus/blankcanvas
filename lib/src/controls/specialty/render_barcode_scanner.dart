// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';


class RenderBarcodeScanner extends RenderBox {
  RenderBarcodeScanner({
    void Function(String code, String format)? onScanned,
    required List<String> formats,
  }) : _onScanned = onScanned,
       _formats = formats {
    _tap = TapGestureRecognizer()..onTap = _handleTap;
  }

  void Function(String code, String format)? _onScanned;
  set onScanned(void Function(String code, String format)? value) =>
      _onScanned = value;

  // ignore: unused_field
  List<String> _formats;
  set formats(List<String> value) => _formats = value;

  late TapGestureRecognizer _tap;
  bool _isScanning = false;
  String? _scannedCode;
  bool _isHovered = false;

  static const double _viewfinderHeight = 180.0;
  static const double _resultHeight = 48.0;

  Rect _scanButtonRect = Rect.zero;

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    size = constraints.constrain(
      Size(constraints.maxWidth, _viewfinderHeight + _resultHeight + 16),
    );
    _scanButtonRect = Rect.fromLTWH(
      size.width / 2 - 60,
      _viewfinderHeight - 20,
      120,
      40,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Viewfinder background
    final viewfinderRect = Rect.fromLTWH(
      offset.dx,
      offset.dy,
      size.width,
      _viewfinderHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(viewfinderRect, const Radius.circular(8)),
      Paint()..color = const Color(0xFF1A1A1A),
    );

    // Scan area
    final scanArea = Rect.fromCenter(
      center: viewfinderRect.center,
      width: size.width * 0.7,
      height: 60,
    );
    canvas.drawRect(
      scanArea,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFF4CAF50)
        ..strokeWidth = 2,
    );

    // Corner brackets
    const bracketSize = 20.0;
    final bracketPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Top-left
    canvas.drawLine(
      Offset(scanArea.left, scanArea.top + bracketSize),
      Offset(scanArea.left, scanArea.top),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(scanArea.left, scanArea.top),
      Offset(scanArea.left + bracketSize, scanArea.top),
      bracketPaint,
    );
    // Top-right
    canvas.drawLine(
      Offset(scanArea.right - bracketSize, scanArea.top),
      Offset(scanArea.right, scanArea.top),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(scanArea.right, scanArea.top),
      Offset(scanArea.right, scanArea.top + bracketSize),
      bracketPaint,
    );
    // Bottom-left
    canvas.drawLine(
      Offset(scanArea.left, scanArea.bottom - bracketSize),
      Offset(scanArea.left, scanArea.bottom),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(scanArea.left, scanArea.bottom),
      Offset(scanArea.left + bracketSize, scanArea.bottom),
      bracketPaint,
    );
    // Bottom-right
    canvas.drawLine(
      Offset(scanArea.right - bracketSize, scanArea.bottom),
      Offset(scanArea.right, scanArea.bottom),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(scanArea.right, scanArea.bottom),
      Offset(scanArea.right, scanArea.bottom - bracketSize),
      bracketPaint,
    );

    // Scanning line
    if (_isScanning) {
      canvas.drawLine(
        Offset(scanArea.left + 4, scanArea.center.dy),
        Offset(scanArea.right - 4, scanArea.center.dy),
        Paint()
          ..color = const Color(0xFFFF5722)
          ..strokeWidth = 2,
      );
    }

    // Scan button
    final buttonRect = _scanButtonRect.shift(offset);
    canvas.drawRRect(
      RRect.fromRectAndRadius(buttonRect, const Radius.circular(20)),
      Paint()
        ..color = _isHovered
            ? const Color(0xFF1976D2)
            : const Color(0xFF2196F3),
    );
    textPainter.text = TextSpan(
      text: _isScanning ? 'Scanning...' : 'Scan Barcode',
      style: const TextStyle(fontSize: 14, color: Color(0xFFFFFFFF)),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      buttonRect.center - Offset(textPainter.width / 2, textPainter.height / 2),
    );

    // Result area
    final resultRect = Rect.fromLTWH(
      offset.dx,
      offset.dy + _viewfinderHeight + 8,
      size.width,
      _resultHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(resultRect, const Radius.circular(8)),
      Paint()..color = const Color(0xFFF5F5F5),
    );

    if (_scannedCode != null) {
      textPainter.text = TextSpan(
        text: '✓ $_scannedCode',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4CAF50),
        ),
      );
    } else {
      textPainter.text = const TextSpan(
        text: 'Point camera at barcode',
        style: TextStyle(fontSize: 14, color: Color(0xFF999999)),
      );
    }
    textPainter.layout();
    textPainter.paint(
      canvas,
      resultRect.center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  void _handleTap() {
    if (!_isScanning) {
      _isScanning = true;
      markNeedsPaint();

      // Simulate scan after delay
      Future.delayed(const Duration(milliseconds: 500), () {
        _isScanning = false;
        _scannedCode = '5901234123457';
        _onScanned?.call(_scannedCode!, 'EAN-13');
        markNeedsPaint();
      });
    }
  }

  void _handleHover(PointerHoverEvent event) {
    final isHovered = _scanButtonRect.contains(event.localPosition);
    if (_isHovered != isHovered) {
      _isHovered = isHovered;
      markNeedsPaint();
    }
  }

  @override
  bool hitTestSelf(Offset position) => _scanButtonRect.contains(position);

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _tap.addPointer(event);
    } else if (event is PointerHoverEvent) {
      _handleHover(event);
    }
  }
}
