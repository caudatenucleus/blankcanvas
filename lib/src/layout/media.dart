import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A widget that displays text with multiple styles.
class RichText extends MultiChildRenderObjectWidget {
  const RichText({
    super.key,
    required this.text,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.softWrap = true,
    this.overflow = TextOverflow.clip,
    this.textScaler = TextScaler.noScaling,
    this.maxLines,
    this.locale,
    this.strutStyle,
    this.textWidthBasis = TextWidthBasis.parent,
    this.textHeightBehavior,
    this.selectionColor,
    this.selectionRegistrar,
  }) : super(children: const <Widget>[]);

  final InlineSpan text;
  final TextAlign textAlign;
  final TextDirection? textDirection;
  final bool softWrap;
  final TextOverflow overflow;
  final TextScaler textScaler;
  final int? maxLines;
  final Locale? locale;
  final StrutStyle? strutStyle;
  final TextWidthBasis textWidthBasis;
  final ui.TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;
  final SelectionRegistrar? selectionRegistrar;

  @override
  RenderParagraph createRenderObject(BuildContext context) {
    return RenderParagraph(
      text,
      textAlign: textAlign,
      textDirection: textDirection ?? TextDirection.ltr,
      softWrap: softWrap,
      overflow: overflow,
      textScaler: textScaler,
      maxLines: maxLines,
      locale: locale,
      strutStyle: strutStyle,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
      registrar: selectionRegistrar,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderParagraph renderObject) {
    renderObject
      ..text = text
      ..textAlign = textAlign
      ..textDirection = textDirection ?? TextDirection.ltr
      ..softWrap = softWrap
      ..overflow = overflow
      ..textScaler = textScaler
      ..maxLines = maxLines
      ..locale = locale
      ..strutStyle = strutStyle
      ..textWidthBasis = textWidthBasis
      ..textHeightBehavior = textHeightBehavior
      ..selectionColor = selectionColor
      ..registrar = selectionRegistrar;
  }
}

/// A widget that displays a raw image.
class RawImage extends SingleChildRenderObjectWidget {
  const RawImage({
    super.key,
    this.image,
    this.debugImageLabel,
    this.width,
    this.height,
    this.scale = 1.0,
    this.color,
    this.opacity,
    this.colorBlendMode,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.centerSlice,
    this.matchTextDirection = false,
    this.invertColors = false,
    this.filterQuality = FilterQuality.low,
    this.isAntiAlias = false,
  });

  final ui.Image? image;
  final String? debugImageLabel;
  final double? width;
  final double? height;
  final double scale;
  final Color? color;
  final Animation<double>? opacity;
  final BlendMode? colorBlendMode;
  final BoxFit? fit;
  final AlignmentGeometry alignment;
  final ImageRepeat repeat;
  final Rect? centerSlice;
  final bool matchTextDirection;
  final bool invertColors;
  final FilterQuality filterQuality;
  final bool isAntiAlias;

  @override
  RenderImage createRenderObject(BuildContext context) {
    return RenderImage(
      image: image,
      debugImageLabel: debugImageLabel,
      width: width,
      height: height,
      scale: scale,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      textDirection: matchTextDirection
          ? Directionality.maybeOf(context)
          : null,
      invertColors: invertColors,
      filterQuality: filterQuality,
      isAntiAlias: isAntiAlias,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderImage renderObject) {
    renderObject
      ..image = image
      ..debugImageLabel = debugImageLabel
      ..width = width
      ..height = height
      ..scale = scale
      ..color = color
      ..opacity = opacity
      ..colorBlendMode = colorBlendMode
      ..fit = fit
      ..alignment = alignment
      ..repeat = repeat
      ..centerSlice = centerSlice
      ..matchTextDirection = matchTextDirection
      ..textDirection = matchTextDirection
          ? Directionality.maybeOf(context)
          : null
      ..invertColors = invertColors
      ..filterQuality = filterQuality
      ..isAntiAlias = isAntiAlias;
  }
}

/// A widget that displays a backend texture.
class RawVideo extends SingleChildRenderObjectWidget {
  const RawVideo({
    super.key,
    required this.textureId,
    this.filterQuality = FilterQuality.low,
    this.freeze = false,
  });

  final int textureId;
  final FilterQuality filterQuality;
  final bool freeze;

  @override
  TextureBox createRenderObject(BuildContext context) {
    return TextureBox(
      textureId: textureId,
      filterQuality: filterQuality,
      freeze: freeze,
    );
  }

  @override
  void updateRenderObject(BuildContext context, TextureBox renderObject) {
    renderObject
      ..textureId = textureId
      ..filterQuality = filterQuality
      ..freeze = freeze;
  }
}
