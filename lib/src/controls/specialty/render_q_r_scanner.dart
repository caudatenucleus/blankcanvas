// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';


class RenderQRScanner extends RenderBox {
  RenderQRScanner({void Function(String data)? onScanned})
    : _onScanned = onScanned {
    _tap = TapGestureRecognizer()..onTap = _handleTap;
  }

  void Function(String data)? _onScanned;
  set onScanned(void Function(String data)? value) => _onScanned = value;

  late TapGestureRecognizer _tap;
  bool _isScanning = false;
  String? _scannedData;
  bool _isHovered = false;

  static const double _viewfinderSize = 200.0;
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
      Size(constraints.maxWidth, _viewfinderSize + _resultHeight + 16),
    );
    _scanButtonRect = Rect.fromLTWH(
      size.width / 2 - 50,
      _viewfinderSize - 20,
      100,
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
      _viewfinderSize,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(viewfinderRect, const Radius.circular(8)),
      Paint()..color = const Color(0xFF1A1A1A),
    );

    // QR scan area (square)
    final scanSize = _viewfinderSize * 0.65;
    final scanArea = Rect.fromCenter(
      center: viewfinderRect.center,
      width: scanSize,
      height: scanSize,
    );

    // Corner brackets
    const bracketSize = 30.0;
    final bracketPaint = Paint()
      ..color = const Color(0xFF2196F3)
      ..strokeWidth = 4
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

    // QR code icon in center
    if (!_isScanning) {
      textPainter.text = const TextSpan(
        text: '⊞',
        style: TextStyle(fontSize: 48, color: Color(0x55FFFFFF)),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        scanArea.center - Offset(textPainter.width / 2, textPainter.height / 2),
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
      text: _isScanning ? '...' : 'Scan QR',
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
      offset.dy + _viewfinderSize + 8,
      size.width,
      _resultHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(resultRect, const Radius.circular(8)),
      Paint()..color = const Color(0xFFF5F5F5),
    );

    if (_scannedData != null) {
      textPainter.text = TextSpan(
        text: '✓ $_scannedData',
        style: const TextStyle(fontSize: 13, color: Color(0xFF4CAF50)),
      );
    } else {
      textPainter.text = const TextSpan(
        text: 'Position QR code in frame',
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

      Future.delayed(const Duration(milliseconds: 400), () {
        _isScanning = false;
        _scannedData = 'https://example.com/action?id=12345';
        _onScanned?.call(_scannedData!);
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
