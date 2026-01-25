import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

import 'package:blankcanvas/src/foundation/status.dart';
import 'package:blankcanvas/src/theme/theme.dart';

/// A user avatar widget with image, label, and status support.
class Avatar extends SingleChildRenderObjectWidget {
  const Avatar({
    super.key,
    this.image,
    Widget? label,
    this.showStatus = false,
    this.tag,
  }) : super(child: label);

  final ImageProvider? image;
  final bool showStatus;
  final String? tag;

  @override
  RenderAvatar createRenderObject(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization =
        customizations.getAvatar(tag) ?? AvatarCustomization.simple();

    return RenderAvatar(
      imageProvider: image,
      showStatus: showStatus,
      customization: customization,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderAvatar renderObject) {
    final customizations = CustomizedTheme.of(context);
    final customization =
        customizations.getAvatar(tag) ?? AvatarCustomization.simple();

    renderObject
      ..imageProvider = image
      ..showStatus = showStatus
      ..customization = customization;
  }
}

class RenderAvatar extends RenderProxyBox {
  RenderAvatar({
    ImageProvider? imageProvider,
    required bool showStatus,
    required AvatarCustomization customization,
    RenderBox? child,
  }) : _imageProvider = imageProvider,
       _showStatus = showStatus,
       _customization = customization,
       super(child);

  ImageProvider? _imageProvider;
  ImageProvider? get imageProvider => _imageProvider;
  set imageProvider(ImageProvider? value) {
    if (_imageProvider == value) return;
    _imageProvider = value;
    _updateImage();
  }

  bool _showStatus;
  bool get showStatus => _showStatus;
  set showStatus(bool value) {
    if (_showStatus == value) return;
    _showStatus = value;
    markNeedsPaint();
  }

  AvatarCustomization _customization;
  AvatarCustomization get customization => _customization;
  set customization(AvatarCustomization value) {
    if (_customization == value) return;
    _customization = value;
    markNeedsLayout();
    markNeedsPaint();
  }

  ImageStream? _imageStream;
  ImageInfo? _imageInfo;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _updateImage();
  }

  @override
  void detach() {
    _imageStream?.removeListener(ImageStreamListener(_handleImageChanged));
    super.detach();
  }

  void _updateImage() {
    _imageStream?.removeListener(ImageStreamListener(_handleImageChanged));
    if (_imageProvider != null) {
      _imageStream = _imageProvider!.resolve(const ImageConfiguration());
      _imageStream!.addListener(ImageStreamListener(_handleImageChanged));
    } else {
      _imageStream = null;
      _imageInfo = null;
      markNeedsPaint();
    }
  }

  void _handleImageChanged(ImageInfo info, bool synchronousCall) {
    _imageInfo = info;
    markNeedsPaint();
  }

  @override
  void performLayout() {
    final double sizeVal = customization.size ?? 48;
    size = constraints.constrain(Size.square(sizeVal));

    if (child != null) {
      child!.layout(BoxConstraints.loose(size), parentUsesSize: true);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Canvas canvas = context.canvas;
    final Rect rect = offset & size;
    final status = MutableControlStatus(); // Default active/enabled

    final decoration = customization.decoration(status);

    // BACKGROUND
    if (decoration is BoxDecoration) {
      final Paint bgPaint = Paint()
        ..color = decoration.color ?? const Color(0xFFEEEEEE);
      if (decoration.shape == BoxShape.circle) {
        canvas.drawCircle(rect.center, size.width / 2, bgPaint);
      } else {
        canvas.drawRect(rect, bgPaint);
      }

      if (decoration.border != null) {
        if (decoration.shape == BoxShape.circle) {
          decoration.border!.paint(canvas, rect, shape: BoxShape.circle);
        } else {
          decoration.border!.paint(canvas, rect);
        }
      }
    } else {
      // Fallback
      final BoxPainter painter = decoration.createBoxPainter();
      painter.paint(canvas, offset, ImageConfiguration(size: size));
      painter.dispose();
    }

    // IMAGE
    if (_imageInfo != null) {
      canvas.save();
      Path clipPath;
      if (decoration is BoxDecoration && decoration.shape == BoxShape.circle) {
        clipPath = Path()..addOval(rect);
      } else {
        // Assume rect for now or use borderRadius if easy access
        clipPath = Path()..addRect(rect);
      }
      canvas.clipPath(clipPath);
      paintImage(
        canvas: canvas,
        rect: rect,
        image: _imageInfo!.image,
        fit: BoxFit.cover,
      );
      canvas.restore();
    } else if (child != null) {
      // CENTER LABEL
      // Provide default text style
      // How to apply text style? Child is already built widget tree.
      // We rely on caller wrapping text? Or we can't easily injection DefaultTextStyle here without caching child.
      // RenderProxyBox logic... child is already layouted.
      // Center it.
      final double dx = offset.dx + (size.width - child!.size.width) / 2;
      final double dy = offset.dy + (size.height - child!.size.height) / 2;
      context.paintChild(child!, Offset(dx, dy));
    }

    // STATUS INDICATOR
    if (showStatus) {
      final double indicatorSize = size.width * 0.25;
      final Offset indicatorPos =
          offset +
          Offset(size.width - indicatorSize, size.height - indicatorSize);

      final Paint statusPaint = Paint()
        ..color = customization.statusColor ?? const Color(0xFF4CAF50);

      canvas.drawCircle(
        indicatorPos + Offset(indicatorSize / 2, indicatorSize / 2),
        indicatorSize / 2,
        statusPaint,
      );

      // Border for indicator
      final Paint borderPaint = Paint()
        ..color = const Color(0xFFFFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(
        indicatorPos + Offset(indicatorSize / 2, indicatorSize / 2),
        indicatorSize / 2,
        borderPaint,
      );
    }
  }
}
