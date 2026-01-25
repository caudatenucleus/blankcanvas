import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

/// A location picker widget.
class LocationPicker extends LeafRenderObjectWidget {
  const LocationPicker({
    super.key,
    this.latitude,
    this.longitude,
    this.onLocationSelected,
    this.showCurrentLocation = true,
    this.tag,
  });

  final double? latitude;
  final double? longitude;
  final void Function(double lat, double lng)? onLocationSelected;
  final bool showCurrentLocation;
  final String? tag;

  @override
  RenderLocationPicker createRenderObject(BuildContext context) {
    return RenderLocationPicker(
      latitude: latitude,
      longitude: longitude,
      onLocationSelected: onLocationSelected,
      showCurrentLocation: showCurrentLocation,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderLocationPicker renderObject,
  ) {
    renderObject
      ..latitude = latitude
      ..longitude = longitude
      ..onLocationSelected = onLocationSelected
      ..showCurrentLocation = showCurrentLocation;
  }
}

class RenderLocationPicker extends RenderBox {
  RenderLocationPicker({
    double? latitude,
    double? longitude,
    void Function(double lat, double lng)? onLocationSelected,
    required bool showCurrentLocation,
  }) : _latitude = latitude ?? 40.7128,
       _longitude = longitude ?? -74.0060,
       _onLocationSelected = onLocationSelected,
       _showCurrentLocation = showCurrentLocation {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  double _latitude;
  set latitude(double? value) {
    if (value != null && _latitude != value) {
      _latitude = value;
      markNeedsPaint();
    }
  }

  double _longitude;
  set longitude(double? value) {
    if (value != null && _longitude != value) {
      _longitude = value;
      markNeedsPaint();
    }
  }

  void Function(double lat, double lng)? _onLocationSelected;
  set onLocationSelected(void Function(double lat, double lng)? value) =>
      _onLocationSelected = value;

  bool _showCurrentLocation;
  set showCurrentLocation(bool value) => _showCurrentLocation = value;

  late TapGestureRecognizer _tap;
  // ignore: unused_field
  final bool _isHovered = false;
  int? _hoveredButton;

  static const double _mapHeight = 180.0;
  static const double _controlHeight = 48.0;

  Rect _myLocationRect = Rect.zero;
  Rect _searchRect = Rect.zero;

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    size = constraints.constrain(
      Size(constraints.maxWidth, _mapHeight + _controlHeight + 8),
    );
    _myLocationRect = Rect.fromLTWH(size.width - 48, 8, 40, 40);
    _searchRect = Rect.fromLTWH(0, _mapHeight + 8, size.width, _controlHeight);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Map placeholder background
    final mapRect = Rect.fromLTWH(offset.dx, offset.dy, size.width, _mapHeight);
    canvas.drawRRect(
      RRect.fromRectAndRadius(mapRect, const Radius.circular(8)),
      Paint()..color = const Color(0xFFE8E8E8),
    );

    // Grid lines to simulate map
    final gridPaint = Paint()
      ..color = const Color(0xFFD0D0D0)
      ..strokeWidth = 1;
    for (int i = 1; i < 8; i++) {
      canvas.drawLine(
        Offset(offset.dx + i * size.width / 8, offset.dy),
        Offset(offset.dx + i * size.width / 8, offset.dy + _mapHeight),
        gridPaint,
      );
      canvas.drawLine(
        Offset(offset.dx, offset.dy + i * _mapHeight / 8),
        Offset(offset.dx + size.width, offset.dy + i * _mapHeight / 8),
        gridPaint,
      );
    }

    // Pin marker at center
    final pinCenter = mapRect.center;
    canvas.drawPath(
      Path()
        ..moveTo(pinCenter.dx, pinCenter.dy + 20)
        ..lineTo(pinCenter.dx - 12, pinCenter.dy - 8)
        ..quadraticBezierTo(
          pinCenter.dx,
          pinCenter.dy - 28,
          pinCenter.dx + 12,
          pinCenter.dy - 8,
        )
        ..close(),
      Paint()..color = const Color(0xFFE53935),
    );
    canvas.drawCircle(
      Offset(pinCenter.dx, pinCenter.dy - 12),
      5,
      Paint()..color = const Color(0xFFFFFFFF),
    );

    // My location button
    final myLocRect = _myLocationRect.shift(offset);
    canvas.drawRRect(
      RRect.fromRectAndRadius(myLocRect, const Radius.circular(8)),
      Paint()
        ..color = _hoveredButton == 0
            ? const Color(0xFFE3F2FD)
            : const Color(0xFFFFFFFF),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(myLocRect, const Radius.circular(8)),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFFE0E0E0),
    );
    textPainter.text = const TextSpan(
      text: '📍',
      style: TextStyle(fontSize: 18),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      myLocRect.center - Offset(textPainter.width / 2, textPainter.height / 2),
    );

    // Search/coordinates bar
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

    // Coordinates
    textPainter.text = TextSpan(
      text:
          '📍 ${_latitude.toStringAsFixed(4)}, ${_longitude.toStringAsFixed(4)}',
      style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
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

  void _handleTapUp(TapUpDetails details) {
    final local = details.localPosition;

    if (_myLocationRect.contains(local)) {
      // Simulate getting current location
      _latitude = 40.7128;
      _longitude = -74.0060;
      _onLocationSelected?.call(_latitude, _longitude);
      markNeedsPaint();
    } else if (local.dy < _mapHeight) {
      // Tap on map - update location
      final normalizedX = local.dx / size.width;
      final normalizedY = local.dy / _mapHeight;
      _longitude = -180 + normalizedX * 360;
      _latitude = 90 - normalizedY * 180;
      _onLocationSelected?.call(_latitude, _longitude);
      markNeedsPaint();
    }
  }

  void _handleHover(PointerHoverEvent event) {
    final local = event.localPosition;
    int? hovered;
    if (_myLocationRect.contains(local)) hovered = 0;

    if (_hoveredButton != hovered) {
      _hoveredButton = hovered;
      markNeedsPaint();
    }
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _tap.addPointer(event);
    } else if (event is PointerHoverEvent) {
      _handleHover(event);
    }
  }
}
