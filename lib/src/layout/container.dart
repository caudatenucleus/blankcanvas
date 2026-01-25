import 'package:flutter/widgets.dart';
// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';

/// A convenience widget that combines common painting, positioning, and sizing widgets.
/// A convenience widget that combines common painting, positioning, and sizing widgets.
class Container extends SingleChildRenderObjectWidget {
  Container({
    super.key,
    this.alignment,
    this.padding,
    this.color,
    this.decoration,
    this.foregroundDecoration,
    double? width,
    double? height,
    BoxConstraints? constraints,
    this.margin,
    this.transform,
    this.transformAlignment,
    super.child,
    this.clipBehavior = Clip.none,
  }) : assert(margin == null || margin.isNonNegative),
       assert(padding == null || padding.isNonNegative),
       assert(decoration == null || decoration.debugAssertIsValid()),
       assert(constraints == null || constraints.debugAssertIsValid()),
       assert(
         color == null || decoration == null,
         'Cannot provide both a color and a decoration\n'
         'The color argument is just a shorthand for "decoration: new BoxDecoration(color: color)".',
       ),
       constraints = (width != null || height != null)
           ? constraints?.tighten(width: width, height: height) ??
                 BoxConstraints.tightFor(width: width, height: height)
           : constraints;

  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Decoration? decoration;
  final Decoration? foregroundDecoration;
  final BoxConstraints? constraints;
  final EdgeInsetsGeometry? margin;
  final Matrix4? transform;
  final AlignmentGeometry? transformAlignment;
  final Clip clipBehavior;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderContainer(
      alignment: alignment,
      padding: padding,
      color: color,
      decoration: decoration,
      foregroundDecoration: foregroundDecoration,
      constraints: constraints,
      margin: margin,
      transform: transform,
      transformAlignment: transformAlignment,
      clipBehavior: clipBehavior,
      textDirection: Directionality.maybeOf(context),
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderContainer renderObject) {
    renderObject
      ..alignment = alignment
      ..padding = padding
      ..color = color
      ..decoration = decoration
      ..foregroundDecoration = foregroundDecoration
      ..additionalConstraints = constraints
      ..margin = margin
      ..transform = transform
      ..transformAlignment = transformAlignment
      ..clipBehavior = clipBehavior
      ..textDirection = Directionality.maybeOf(context);
  }
}

class RenderContainer extends RenderProxyBox {
  RenderContainer({
    AlignmentGeometry? alignment,
    EdgeInsetsGeometry? padding,
    Color? color,
    Decoration? decoration,
    Decoration? foregroundDecoration,
    BoxConstraints? constraints,
    EdgeInsetsGeometry? margin,
    Matrix4? transform,
    AlignmentGeometry? transformAlignment,
    Clip clipBehavior = Clip.none,
    TextDirection? textDirection,
  }) : _alignment = alignment,
       _padding = padding,
       _color = color,
       _decoration = decoration,
       _foregroundDecoration = foregroundDecoration,
       _additionalConstraints = constraints,
       _margin = margin,
       _transform = transform,
       _transformAlignment = transformAlignment,
       _clipBehavior = clipBehavior,
       _textDirection = textDirection;

  AlignmentGeometry? _alignment;
  set alignment(AlignmentGeometry? value) {
    if (_alignment == value) return;
    _alignment = value;
    markNeedsLayout();
  }

  EdgeInsetsGeometry? _padding;
  set padding(EdgeInsetsGeometry? value) {
    if (_padding == value) return;
    _padding = value;
    markNeedsLayout();
  }

  Color? _color;
  set color(Color? value) {
    if (_color == value) return;
    _color = value;
    markNeedsPaint();
  }

  Decoration? _decoration;
  set decoration(Decoration? value) {
    if (_decoration == value) return;
    _decoration = value;
    markNeedsPaint();
  }

  Decoration? _foregroundDecoration;
  set foregroundDecoration(Decoration? value) {
    if (_foregroundDecoration == value) return;
    _foregroundDecoration = value;
    markNeedsPaint();
  }

  BoxConstraints? _additionalConstraints;
  set additionalConstraints(BoxConstraints? value) {
    if (_additionalConstraints == value) return;
    _additionalConstraints = value;
    markNeedsLayout();
  }

  EdgeInsetsGeometry? _margin;
  set margin(EdgeInsetsGeometry? value) {
    if (_margin == value) return;
    _margin = value;
    markNeedsLayout();
  }

  Matrix4? _transform;
  set transform(Matrix4? value) {
    if (_transform == value) return;
    _transform = value;
    markNeedsPaint();
  }

  AlignmentGeometry? _transformAlignment;
  set transformAlignment(AlignmentGeometry? value) {
    if (_transformAlignment == value) return;
    _transformAlignment = value;
    markNeedsPaint();
  }

  Clip _clipBehavior;
  set clipBehavior(Clip value) {
    if (_clipBehavior == value) return;
    _clipBehavior = value;
    markNeedsPaint();
  }

  TextDirection? _textDirection;
  set textDirection(TextDirection? value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    // This is a simplified implementation.
    // In a full implementation, we'd need to resolve all geometries.
    final resolvedPadding = _padding?.resolve(_textDirection);
    final resolvedMargin = _margin?.resolve(_textDirection);

    BoxConstraints innerConstraints = constraints;
    if (resolvedMargin != null) {
      innerConstraints = innerConstraints.deflate(resolvedMargin);
    }
    if (_additionalConstraints != null) {
      innerConstraints = innerConstraints.enforce(_additionalConstraints!);
    }
    if (resolvedPadding != null) {
      innerConstraints = innerConstraints.deflate(resolvedPadding);
    }

    if (child != null) {
      child!.layout(innerConstraints, parentUsesSize: true);

      Size childSize = child!.size;
      if (resolvedPadding != null) {
        childSize = Size(
          childSize.width + resolvedPadding.horizontal,
          childSize.height + resolvedPadding.vertical,
        );
      }
      if (resolvedMargin != null) {
        childSize = Size(
          childSize.width + resolvedMargin.horizontal,
          childSize.height + resolvedMargin.vertical,
        );
      }
      size = constraints.constrain(childSize);

      final pd = child!.parentData as BoxParentData;
      pd.offset = Offset(
        (resolvedMargin?.left ?? 0) + (resolvedPadding?.left ?? 0),
        (resolvedMargin?.top ?? 0) + (resolvedPadding?.top ?? 0),
      );
    } else {
      size = constraints.constrain(Size.zero);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_color != null) {
      context.canvas.drawRect(offset & size, Paint()..color = _color!);
    }
    if (_decoration != null) {
      // Simplified decoration painting
    }
    super.paint(context, offset);
    if (_foregroundDecoration != null) {
      // Simplified foreground decoration painting
    }
  }
}

// Helper widgets needed for Container
class DecoratedBox extends SingleChildRenderObjectWidget {
  const DecoratedBox({
    super.key,
    required this.decoration,
    this.position = DecorationPosition.background,
    super.child,
  });

  final Decoration decoration;
  final DecorationPosition position;

  @override
  RenderDecoratedBox createRenderObject(BuildContext context) {
    return RenderDecoratedBox(
      decoration: decoration,
      position: position,
      configuration: ImageConfiguration.empty, // simplified
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderDecoratedBox renderObject,
  ) {
    renderObject
      ..decoration = decoration
      ..position = position;
  }
}

class ConstrainedBox extends SingleChildRenderObjectWidget {
  const ConstrainedBox({super.key, required this.constraints, super.child});

  final BoxConstraints constraints;

  @override
  RenderConstrainedBox createRenderObject(BuildContext context) {
    return RenderConstrainedBox(additionalConstraints: constraints);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderConstrainedBox renderObject,
  ) {
    renderObject.additionalConstraints = constraints;
  }
}

class LimitedBox extends SingleChildRenderObjectWidget {
  const LimitedBox({
    super.key,
    this.maxWidth = double.infinity,
    this.maxHeight = double.infinity,
    super.child,
  });

  final double maxWidth;
  final double maxHeight;

  @override
  RenderLimitedBox createRenderObject(BuildContext context) {
    return RenderLimitedBox(maxWidth: maxWidth, maxHeight: maxHeight);
  }

  @override
  void updateRenderObject(BuildContext context, RenderLimitedBox renderObject) {
    renderObject
      ..maxWidth = maxWidth
      ..maxHeight = maxHeight;
  }
}

class Transform extends SingleChildRenderObjectWidget {
  const Transform({
    super.key,
    required this.transform,
    this.origin,
    this.alignment,
    this.transformHitTests = true,
    this.filterQuality,
    super.child,
  });

  final Matrix4 transform;
  final Offset? origin;
  final AlignmentGeometry? alignment;
  final bool transformHitTests;
  final FilterQuality? filterQuality;

  @override
  RenderTransform createRenderObject(BuildContext context) {
    return RenderTransform(
      transform: transform,
      origin: origin,
      alignment: alignment,
      textDirection: Directionality.maybeOf(context),
      transformHitTests: transformHitTests,
      filterQuality: filterQuality,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderTransform renderObject) {
    renderObject
      ..transform = transform
      ..origin = origin
      ..alignment = alignment
      ..textDirection = Directionality.maybeOf(context)
      ..transformHitTests = transformHitTests
      ..filterQuality = filterQuality;
  }
}

/// A widget that tries to match the ambient directionality.
