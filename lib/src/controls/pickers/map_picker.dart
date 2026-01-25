import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

/// A map picker widget for selecting locations on a map.
class MapPicker extends LeafRenderObjectWidget {
  const MapPicker({
    super.key,
    this.latitude,
    this.longitude,
    this.zoom = 12,
    this.onLocationSelected,
    this.showSearch = true,
    this.tag,
  });

  final double? latitude;
  final double? longitude;
  final int zoom;
  final void Function(double lat, double lng)? onLocationSelected;
  final bool showSearch;
  final String? tag;

  @override
  RenderMapPicker createRenderObject(BuildContext context) {
    return RenderMapPicker(
      latitude: latitude ?? 40.7128,
      longitude: longitude ?? -74.0060,
      zoom: zoom,
      onLocationSelected: onLocationSelected,
      showSearch: showSearch,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderMapPicker renderObject) {
    renderObject
      ..latitude = latitude ?? 40.7128
      ..longitude = longitude ?? -74.0060
      ..zoom = zoom
      ..onLocationSelected = onLocationSelected
      ..showSearch = showSearch;
  }
}

class RenderMapPicker extends RenderBox {
  RenderMapPicker({
    required double latitude,
    required double longitude,
    required int zoom,
    void Function(double lat, double lng)? onLocationSelected,
    required bool showSearch,
  }) : _latitude = latitude,
       _longitude = longitude,
       _zoom = zoom,
       _onLocationSelected = onLocationSelected,
       _showSearch = showSearch {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
    _pan = PanGestureRecognizer()..onUpdate = _handlePanUpdate;
  }

  double _latitude;
  set latitude(double value) {
    _latitude = value;
    markNeedsPaint();
  }

  double _longitude;
  set longitude(double value) {
    _longitude = value;
    markNeedsPaint();
  }

  int _zoom;
  set zoom(int value) {
    _zoom = value;
    markNeedsPaint();
  }

  void Function(double lat, double lng)? _onLocationSelected;
  set onLocationSelected(void Function(double lat, double lng)? value) =>
      _onLocationSelected = value;

  bool _showSearch;
  set showSearch(bool value) {
    _showSearch = value;
    markNeedsLayout();
  }

  late TapGestureRecognizer _tap;
  late PanGestureRecognizer _pan;
  int? _hoveredControl;

  static const double _mapHeight = 250.0;
  static const double _searchHeight = 44.0;
  static const double _controlSize = 36.0;

  Rect _zoomInRect = Rect.zero;
  Rect _zoomOutRect = Rect.zero;
  Rect _searchRect = Rect.zero;

  @override
  void detach() {
    _tap.dispose();
    _pan.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    final searchSpace = _showSearch ? _searchHeight + 8 : 0.0;
    size = constraints.constrain(
      Size(constraints.maxWidth, _mapHeight + searchSpace),
    );

    _zoomInRect = Rect.fromLTWH(
      size.width - _controlSize - 8,
      _mapHeight / 2 - _controlSize - 4,
      _controlSize,
      _controlSize,
    );
    _zoomOutRect = Rect.fromLTWH(
      size.width - _controlSize - 8,
      _mapHeight / 2 + 4,
      _controlSize,
      _controlSize,
    );

    if (_showSearch) {
      _searchRect = Rect.fromLTWH(0, _mapHeight + 8, size.width, _searchHeight);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Map background
    final mapRect = Rect.fromLTWH(offset.dx, offset.dy, size.width, _mapHeight);
    canvas.drawRRect(
      RRect.fromRectAndRadius(mapRect, const Radius.circular(8)),
      Paint()..color = const Color(0xFFE8E8E8),
    );

    // Grid to simulate map tiles
    final gridPaint = Paint()
      ..color = const Color(0xFFD0D0D0)
      ..strokeWidth = 1;
    final gridSize = 40.0 + _zoom * 5;
    for (double x = offset.dx; x < offset.dx + size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, offset.dy),
        Offset(x, offset.dy + _mapHeight),
        gridPaint,
      );
    }
    for (double y = offset.dy; y < offset.dy + _mapHeight; y += gridSize) {
      canvas.drawLine(
        Offset(offset.dx, y),
        Offset(offset.dx + size.width, y),
        gridPaint,
      );
    }

    // Roads simulation
    canvas.drawLine(
      Offset(offset.dx, offset.dy + _mapHeight / 2),
      Offset(offset.dx + size.width, offset.dy + _mapHeight / 2),
      Paint()
        ..color = const Color(0xFFBBBBBB)
        ..strokeWidth = 3,
    );
    canvas.drawLine(
      Offset(offset.dx + size.width / 2, offset.dy),
      Offset(offset.dx + size.width / 2, offset.dy + _mapHeight),
      Paint()
        ..color = const Color(0xFFBBBBBB)
        ..strokeWidth = 3,
    );

    // Pin marker at center
    final pinCenter = mapRect.center;
    final pinPath = Path()
      ..moveTo(pinCenter.dx, pinCenter.dy + 20)
      ..lineTo(pinCenter.dx - 12, pinCenter.dy - 8)
      ..quadraticBezierTo(
        pinCenter.dx,
        pinCenter.dy - 28,
        pinCenter.dx + 12,
        pinCenter.dy - 8,
      )
      ..close();
    canvas.drawPath(pinPath, Paint()..color = const Color(0xFFE53935));
    canvas.drawCircle(
      Offset(pinCenter.dx, pinCenter.dy - 12),
      5,
      Paint()..color = const Color(0xFFFFFFFF),
    );

    // Zoom controls
    _drawZoomControl(
      canvas,
      _zoomInRect.shift(offset),
      '+',
      _hoveredControl == 0,
    );
    _drawZoomControl(
      canvas,
      _zoomOutRect.shift(offset),
      '−',
      _hoveredControl == 1,
    );

    // Coordinates display
    textPainter.text = TextSpan(
      text:
          '${_latitude.toStringAsFixed(4)}, ${_longitude.toStringAsFixed(4)} | Zoom: $_zoom',
      style: const TextStyle(fontSize: 11, color: Color(0xFF333333)),
    );
    textPainter.layout();

    final coordBg = Rect.fromLTWH(
      offset.dx + 8,
      offset.dy + 8,
      textPainter.width + 16,
      24,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(coordBg, const Radius.circular(4)),
      Paint()..color = const Color(0xDDFFFFFF),
    );
    textPainter.paint(
      canvas,
      Offset(coordBg.left + 8, coordBg.center.dy - textPainter.height / 2),
    );

    // Search box
    if (_showSearch) {
      final searchRect = _searchRect.shift(offset);
      canvas.drawRRect(
        RRect.fromRectAndRadius(searchRect, const Radius.circular(8)),
        Paint()..color = const Color(0xFFFFFFFF),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(searchRect, const Radius.circular(8)),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = const Color(0xFFE0E0E0),
      );

      textPainter.text = const TextSpan(
        text: '🔍 Search location...',
        style: TextStyle(fontSize: 14, color: Color(0xFF999999)),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          searchRect.left + 12,
          searchRect.center.dy - textPainter.height / 2,
        ),
      );
    }
  }

  void _drawZoomControl(
    Canvas canvas,
    Rect rect,
    String symbol,
    bool isHovered,
  ) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      Paint()
        ..color = isHovered ? const Color(0xFF2196F3) : const Color(0xFFFFFFFF),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFFE0E0E0),
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: symbol,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: isHovered ? const Color(0xFFFFFFFF) : const Color(0xFF333333),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      rect.center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  void _handleTapUp(TapUpDetails details) {
    final local = details.localPosition;

    if (_zoomInRect.contains(local)) {
      _zoom = (_zoom + 1).clamp(1, 20);
      markNeedsPaint();
    } else if (_zoomOutRect.contains(local)) {
      _zoom = (_zoom - 1).clamp(1, 20);
      markNeedsPaint();
    } else if (local.dy < _mapHeight) {
      // Tap on map - update pin location
      final normalizedX = local.dx / size.width;
      final normalizedY = local.dy / _mapHeight;
      _longitude = -180 + normalizedX * 360;
      _latitude = 90 - normalizedY * 180;
      _onLocationSelected?.call(_latitude, _longitude);
      markNeedsPaint();
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    // Pan the map
    _longitude -= details.delta.dx * 0.01;
    _latitude += details.delta.dy * 0.01;
    _longitude = _longitude.clamp(-180, 180);
    _latitude = _latitude.clamp(-90, 90);
    markNeedsPaint();
  }

  void _handleHover(PointerHoverEvent event) {
    final local = event.localPosition;
    int? hovered;
    if (_zoomInRect.contains(local)) {
      hovered = 0;
    } else if (_zoomOutRect.contains(local))
      hovered = 1;

    if (_hoveredControl != hovered) {
      _hoveredControl = hovered;
      markNeedsPaint();
    }
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _tap.addPointer(event);
      _pan.addPointer(event);
    } else if (event is PointerHoverEvent) {
      _handleHover(event);
    }
  }
}
