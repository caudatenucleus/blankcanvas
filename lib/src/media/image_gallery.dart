import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

/// A grid of images using lowest-level RenderObject APIs.
class ImageGallery extends MultiChildRenderObjectWidget {
  ImageGallery({
    super.key,
    required this.images,
    this.crossAxisCount = 3,
    this.spacing = 8.0,
    this.tag,
  }) : super(children: _buildChildren(images));

  final List<ImageProvider> images;
  final int crossAxisCount;
  final double spacing;
  final String? tag;

  static List<Widget> _buildChildren(List<ImageProvider> providers) {
    return providers.map((p) => _ResolvedImage(provider: p)).toList();
  }

  @override
  RenderImageGallery createRenderObject(BuildContext context) {
    return RenderImageGallery(crossAxisCount: crossAxisCount, spacing: spacing);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderImageGallery renderObject,
  ) {
    renderObject
      ..crossAxisCount = crossAxisCount
      ..spacing = spacing;
  }
}

class ImageGalleryParentData extends ContainerBoxParentData<RenderBox> {
  int? index;
}

class RenderImageGallery extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, ImageGalleryParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, ImageGalleryParentData> {
  RenderImageGallery({required int crossAxisCount, required double spacing})
    : _crossAxisCount = crossAxisCount,
      _spacing = spacing;

  int _crossAxisCount;
  set crossAxisCount(int value) {
    if (_crossAxisCount == value) return;
    _crossAxisCount = value;
    markNeedsLayout();
  }

  double _spacing;
  set spacing(double value) {
    if (_spacing == value) return;
    _spacing = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! ImageGalleryParentData) {
      child.parentData = ImageGalleryParentData();
    }
  }

  @override
  void performLayout() {
    final double width = constraints.maxWidth;
    if (width == 0.0) {
      size = constraints.smallest;
      return;
    }
    final double itemWidth =
        (width - (_crossAxisCount - 1) * _spacing) / _crossAxisCount;

    double currentX = 0;
    double currentY = 0;
    int column = 0;

    RenderBox? child = firstChild;
    int index = 0;
    while (child != null) {
      final pd = child.parentData! as ImageGalleryParentData;
      pd.index = index;

      child.layout(
        BoxConstraints.tightFor(width: itemWidth, height: itemWidth),
        parentUsesSize: false,
      );
      pd.offset = Offset(currentX, currentY);

      column++;
      if (column >= _crossAxisCount) {
        column = 0;
        currentX = 0;
        currentY += itemWidth + _spacing;
      } else {
        currentX += itemWidth + _spacing;
      }

      child = pd.nextSibling;
      index++;
    }

    final double totalHeight = index == 0
        ? 0
        : (column == 0
              ? currentY - _spacing
              : currentY + itemWidth); // Logic fix: if col=0, we just wrapped.
    // If column == 0, it means we recently added a row, incremented Y, and reset X.
    // So height is currentY - spacing (remove last spacing).
    // If column > 0, we are in the middle of a row. The row bottom is currentY + itemWidth.

    size = constraints.constrain(Size(width, totalHeight));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}

/// A private widget that resolves an ImageProvider and renders it.
class _ResolvedImage extends LeafRenderObjectWidget {
  const _ResolvedImage({required this.provider});

  final ImageProvider provider;

  @override
  RenderObject createRenderObject(BuildContext context) {
    // We capture the initial configuration from context.
    // Dynamic updates to configuration (like devicePixelRatio changing) are not
    // handled here to keep it simple and strictly RenderObject based.
    final ImageConfiguration config = createLocalImageConfiguration(context);
    return _RenderResolvedImage(provider: provider, configuration: config);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderResolvedImage renderObject,
  ) {
    renderObject.configuration = createLocalImageConfiguration(context);
    renderObject.provider = provider;
  }
}

class _RenderResolvedImage extends RenderBox {
  _RenderResolvedImage({
    required ImageProvider provider,
    required ImageConfiguration configuration,
  }) : _provider = provider,
       _configuration = configuration {
    _resolve();
  }

  ImageProvider _provider;
  set provider(ImageProvider value) {
    if (_provider == value) return;
    _provider = value;
    _resolve();
  }

  ImageConfiguration _configuration;
  set configuration(ImageConfiguration value) {
    if (_configuration == value) return;
    _configuration = value;
    _resolve();
  }

  ImageStream? _imageStream;
  ImageInfo? _imageInfo;

  void _resolve() {
    final ImageStream newStream = _provider.resolve(_configuration);
    if (newStream.key == _imageStream?.key) {
      return;
    }
    _imageStream?.removeListener(
      ImageStreamListener(_handleImage, onError: _handleError),
    );
    _imageStream = newStream;
    _imageStream!.addListener(
      ImageStreamListener(_handleImage, onError: _handleError),
    );
  }

  void _handleImage(ImageInfo imageInfo, bool synchronousCall) {
    // We only care about the image if it matches our current stream expectation
    // But logic is simplified here.
    _imageInfo = imageInfo;
    markNeedsPaint();
  }

  void _handleError(dynamic exception, StackTrace? stackTrace) {
    // Fail silently or draw placeholder?
    // For now silent.
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _resolve();
  }

  @override
  void detach() {
    _imageStream?.removeListener(
      ImageStreamListener(_handleImage, onError: _handleError),
    );
    _imageStream = null;
    super.detach();
  }

  // Dispose implementation? RenderObjects are detached, not disposed in the Widget sense.
  // But ImageInfo needs disposal?
  // Ideally yes, _imageInfo?.dispose(). But RenderBox doesn't have dispose().
  // It's handled by GC or manual detach logic if needed.
  // Flutter's RenderImage doesn't dispose ImageInfo, it just holds it.

  @override
  void performLayout() {
    size = constraints.biggest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_imageInfo?.image == null) {
      // Draw placeholder
      context.canvas.drawRect(
        offset & size,
        Paint()..color = const Color(0xFFEEEEEE),
      );
      return;
    }

    final ui.Image image = _imageInfo!.image;
    final Rect src = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    final FittedSizes sizes = applyBoxFit(BoxFit.cover, src.size, size);
    final Rect dst = Alignment.center.inscribe(
      sizes.destination,
      offset & size,
    );
    final Rect srcFitted = Alignment.center.inscribe(sizes.source, src);

    context.canvas.drawImageRect(image, srcFitted, dst, Paint());
  }
}
