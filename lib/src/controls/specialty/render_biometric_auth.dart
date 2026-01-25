// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'biometric_auth.dart';


class RenderBiometricAuth extends RenderBox {
  RenderBiometricAuth({
    void Function(bool success, BiometricMethod method)? onAuthenticated,
    required List<BiometricMethod> supportedMethods,
  }) : _onAuthenticated = onAuthenticated,
       _supportedMethods = supportedMethods {
    _tap = TapGestureRecognizer()..onTap = _handleTap;
  }

  void Function(bool success, BiometricMethod method)? _onAuthenticated;
  set onAuthenticated(
    void Function(bool success, BiometricMethod method)? value,
  ) => _onAuthenticated = value;

  List<BiometricMethod> _supportedMethods;
  set supportedMethods(List<BiometricMethod> value) {
    _supportedMethods = value;
    markNeedsPaint();
  }

  late TapGestureRecognizer _tap;
  bool _isAuthenticating = false;
  bool? _authResult;
  final int _selectedMethod = 0;
  bool _isHovered = false;

  static const double _iconSize = 80.0;

  Rect _authButtonRect = Rect.zero;

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    size = constraints.constrain(const Size(double.infinity, 180));
    _authButtonRect = Rect.fromCircle(
      center: Offset(size.width / 2, 70),
      radius: _iconSize / 2,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final center = offset + Offset(size.width / 2, 70);

    // Background circle
    if (_isAuthenticating) {
      // Pulsing effect
      for (int i = 2; i >= 0; i--) {
        canvas.drawCircle(
          center,
          _iconSize / 2 + 8 + i * 8,
          Paint()
            ..color = const Color(0xFF2196F3).withValues(alpha: 0.1 + i * 0.05),
        );
      }
    }

    // Auth button
    Color buttonColor;
    if (_authResult == true) {
      buttonColor = const Color(0xFF4CAF50);
    } else if (_authResult == false) {
      buttonColor = const Color(0xFFE53935);
    } else {
      buttonColor = _isHovered
          ? const Color(0xFF1976D2)
          : const Color(0xFF2196F3);
    }

    canvas.drawCircle(center, _iconSize / 2, Paint()..color = buttonColor);

    // Icon based on method
    final method = _supportedMethods[_selectedMethod];
    String icon;
    switch (method) {
      case BiometricMethod.fingerprint:
        icon = '👆';
        break;
      case BiometricMethod.faceId:
        icon = '😊';
        break;
      case BiometricMethod.iris:
        icon = '👁';
        break;
    }

    if (_authResult == true) {
      icon = '✓';
    } else if (_authResult == false) {
      icon = '✕';
    }

    textPainter.text = TextSpan(
      text: icon,
      style: const TextStyle(fontSize: 36, color: Color(0xFFFFFFFF)),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );

    // Status text
    String statusText;
    if (_isAuthenticating) {
      statusText = 'Authenticating...';
    } else if (_authResult == true) {
      statusText = 'Authentication successful';
    } else if (_authResult == false) {
      statusText = 'Authentication failed';
    } else {
      statusText = 'Tap to authenticate';
    }

    textPainter.text = TextSpan(
      text: statusText,
      style: TextStyle(
        fontSize: 14,
        color: _authResult == true
            ? const Color(0xFF4CAF50)
            : _authResult == false
            ? const Color(0xFFE53935)
            : const Color(0xFF666666),
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        offset.dx + size.width / 2 - textPainter.width / 2,
        offset.dy + 130,
      ),
    );

    // Method selector if multiple methods
    if (_supportedMethods.length > 1) {
      textPainter.text = TextSpan(
        text: 'Using: ${method.name}',
        style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          offset.dx + size.width / 2 - textPainter.width / 2,
          offset.dy + 155,
        ),
      );
    }
  }

  void _handleTap() {
    if (_isAuthenticating) return;

    _isAuthenticating = true;
    _authResult = null;
    markNeedsPaint();

    // Simulate authentication
    Future.delayed(const Duration(milliseconds: 800), () {
      _isAuthenticating = false;
      _authResult = true; // Simulate success
      _onAuthenticated?.call(true, _supportedMethods[_selectedMethod]);
      markNeedsPaint();
    });
  }

  void _handleHover(PointerHoverEvent event) {
    final isHovered = _authButtonRect.contains(event.localPosition);
    if (_isHovered != isHovered) {
      _isHovered = isHovered;
      markNeedsPaint();
    }
  }

  @override
  bool hitTestSelf(Offset position) => _authButtonRect.contains(position);

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _tap.addPointer(event);
    } else if (event is PointerHoverEvent) {
      _handleHover(event);
    }
  }
}
