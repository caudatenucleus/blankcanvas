// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'workspace_profile_data.dart';


class RenderWorkspaceProfileSelector extends RenderBox {
  RenderWorkspaceProfileSelector({
    required List<WorkspaceProfileData> profiles,
    required String selectedProfileId,
    required double itemHeight,
    required Color backgroundColor,
    required Color selectedColor,
    required Color hoverColor,
    required Color textColor,
  }) : _profiles = profiles,
       _selectedProfileId = selectedProfileId,
       _itemHeight = itemHeight,
       _backgroundColor = backgroundColor,
       _selectedColor = selectedColor,
       _hoverColor = hoverColor,
       _textColor = textColor;

  List<WorkspaceProfileData> _profiles;
  List<WorkspaceProfileData> get profiles => _profiles;
  set profiles(List<WorkspaceProfileData> value) {
    if (_profiles != value) {
      _profiles = value;
      markNeedsLayout();
    }
  }

  String _selectedProfileId;
  String get selectedProfileId => _selectedProfileId;
  set selectedProfileId(String value) {
    if (_selectedProfileId != value) {
      _selectedProfileId = value;
      markNeedsPaint();
    }
  }

  double _itemHeight;
  double get itemHeight => _itemHeight;
  set itemHeight(double value) {
    if (_itemHeight != value) {
      _itemHeight = value;
      markNeedsLayout();
    }
  }

  Color _backgroundColor;
  Color get backgroundColor => _backgroundColor;
  set backgroundColor(Color value) {
    if (_backgroundColor != value) {
      _backgroundColor = value;
      markNeedsPaint();
    }
  }

  Color _selectedColor;
  Color get selectedColor => _selectedColor;
  set selectedColor(Color value) {
    if (_selectedColor != value) {
      _selectedColor = value;
      markNeedsPaint();
    }
  }

  Color _hoverColor;
  Color get hoverColor => _hoverColor;
  set hoverColor(Color value) {
    if (_hoverColor != value) {
      _hoverColor = value;
      markNeedsPaint();
    }
  }

  Color _textColor;
  Color get textColor => _textColor;
  set textColor(Color value) {
    if (_textColor != value) {
      _textColor = value;
      markNeedsPaint();
    }
  }

  @override
  void performLayout() {
    size = Size(constraints.maxWidth, _profiles.length * _itemHeight);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    // Background
    final bgPaint = Paint()..color = _backgroundColor;
    canvas.drawRect(
      Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height),
      bgPaint,
    );

    // Draw each profile item
    for (int i = 0; i < _profiles.length; i++) {
      final profile = _profiles[i];
      final isSelected = profile.id == _selectedProfileId;
      final itemRect = Rect.fromLTWH(
        offset.dx,
        offset.dy + i * _itemHeight,
        size.width,
        _itemHeight,
      );

      // Item background
      if (isSelected) {
        final selectedPaint = Paint()
          ..color = _selectedColor.withValues(alpha: 0.2);
        canvas.drawRect(itemRect, selectedPaint);

        // Selection indicator
        final indicatorPaint = Paint()..color = _selectedColor;
        canvas.drawRect(
          Rect.fromLTWH(itemRect.left, itemRect.top, 3, _itemHeight),
          indicatorPaint,
        );
      }

      // Profile name
      final textBuilder = ui.ParagraphBuilder(ui.ParagraphStyle())
        ..pushStyle(
          ui.TextStyle(
            color: isSelected ? _selectedColor : _textColor,
            fontSize: 13,
          ),
        )
        ..addText(profile.name);

      final paragraph = textBuilder.build()
        ..layout(ui.ParagraphConstraints(width: size.width - 24));

      canvas.drawParagraph(
        paragraph,
        Offset(
          itemRect.left + 12,
          itemRect.top + (_itemHeight - paragraph.height) / 2,
        ),
      );
    }
  }

  @override
  bool hitTestSelf(Offset position) => true;

  /// Returns profile id at position
  String? getProfileAt(Offset localPosition) {
    final index = (localPosition.dy / _itemHeight).floor();
    if (index >= 0 && index < _profiles.length) {
      return _profiles[index].id;
    }
    return null;
  }
}
