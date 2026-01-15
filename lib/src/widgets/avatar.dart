import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import '../foundation/status.dart';
import '../theme/customization.dart';
import '../theme/theme.dart';

/// A user avatar widget with image, label, and status support.
class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    this.image,
    this.label,
    this.showStatus = false,
    this.tag,
  });

  final ImageProvider? image;
  final Widget? label;
  final bool showStatus;
  final String? tag;

  @override
  Widget build(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization =
        customizations.getAvatar(tag) ?? AvatarCustomization.simple();

    return _AvatarRenderWidget(
      image: image,
      label: label,
      showStatus: showStatus,
      customization: customization,
    );
  }
}

class _AvatarRenderWidget extends SingleChildRenderObjectWidget {
  const _AvatarRenderWidget({
    this.image,
    Widget? label,
    required this.showStatus,
    required this.customization,
  }) : super(child: label);

  final ImageProvider? image;
  final bool showStatus;
  final AvatarCustomization customization;

  @override
  RenderAvatar createRenderObject(BuildContext context) => RenderAvatar(
    imageProvider: image,
    showStatus: showStatus,
    customization: customization,
  );

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderAvatar renderObject,
  ) {
    renderObject
      ..imageProvider = image
      ..showStatus = showStatus
      ..customization = customization;
  }
}

class RenderAvatar extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  RenderAvatar({
    ImageProvider? imageProvider,
    required bool showStatus,
    required AvatarCustomization customization,
  }) : _imageProvider = imageProvider,
       _showStatus = showStatus,
       _customization = customization;

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
  }

  ImageStream? _imageStream;
  ImageInfo? _imageInfo;

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
  void detach() {
    _imageStream?.removeListener(ImageStreamListener(_handleImageChanged));
    super.detach();
  }

  @override
  void performLayout() {
    final double sizeVal = customization.size ?? 48;
    size = constraints.constrain(Size(sizeVal, sizeVal));

    if (child != null) {
      child!.layout(BoxConstraints.loose(size), parentUsesSize: true);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final Rect rect = offset & size;
    final status = MutableControlStatus();

    final decoration = customization.decoration(status);

    if (decoration is BoxDecoration) {
      final Paint bgPaint = Paint()
        ..color = decoration.color ?? const Color(0xFFEEEEEE);
      if (decoration.shape == BoxShape.circle) {
        canvas.drawCircle(rect.center, size.width / 2, bgPaint);
      } else {
        canvas.drawRect(rect, bgPaint);
      }
    }

    // Paint Image
    if (_imageInfo != null) {
      canvas.save();
      final Path clipPath = Path()..addOval(rect);
      canvas.clipPath(clipPath);
      paintImage(
        canvas: canvas,
        rect: rect,
        image: _imageInfo!.image,
        fit: BoxFit.cover,
      );
      canvas.restore();
    } else if (child != null) {
      // Center label
      final double dx = offset.dx + (size.width - child!.size.width) / 2;
      final double dy = offset.dy + (size.height - child!.size.height) / 2;
      context.paintChild(child!, Offset(dx, dy));
    }

    // Paint Status
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

  @override
  bool hitTestSelf(Offset position) => true;
}
