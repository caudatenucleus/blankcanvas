// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'render_knob.dart';


/// A rotary knob/dial input widget using custom RenderObject.
class Knob extends LeafRenderObjectWidget {
  const Knob({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.size = 60.0,
    this.color = const Color(0xFF2196F3),
    this.trackColor = const Color(0xFFE0E0E0),
    this.tag,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final double size;
  final Color color;
  final Color trackColor;
  final String? tag;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderKnob(
      value: value,
      onChanged: onChanged,
      min: min,
      max: max,
      size: size,
      color: color,
      trackColor: trackColor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderKnob renderObject) {
    renderObject
      ..value = value
      ..onChanged = onChanged
      ..min = min
      ..max = max
      ..knobSize = size
      ..color = color
      ..trackColor = trackColor;
  }
}
