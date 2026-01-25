import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

/// A file picker widget.
class FilePicker extends LeafRenderObjectWidget {
  const FilePicker({
    super.key,
    this.onFilesSelected,
    this.accept,
    this.multiple = false,
    this.maxSize,
    this.placeholder = 'Drop files here or click to browse',
    this.tag,
  });

  final void Function(List<String> files)? onFilesSelected;
  final List<String>? accept;
  final bool multiple;
  final int? maxSize;
  final String placeholder;
  final String? tag;

  @override
  RenderFilePicker createRenderObject(BuildContext context) {
    return RenderFilePicker(
      onFilesSelected: onFilesSelected,
      accept: accept,
      multiple: multiple,
      maxSize: maxSize,
      placeholder: placeholder,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderFilePicker renderObject) {
    renderObject
      ..onFilesSelected = onFilesSelected
      ..accept = accept
      ..multiple = multiple
      ..maxSize = maxSize
      ..placeholder = placeholder;
  }
}

class RenderFilePicker extends RenderBox {
  RenderFilePicker({
    void Function(List<String> files)? onFilesSelected,
    List<String>? accept,
    required bool multiple,
    int? maxSize,
    required String placeholder,
  }) : _onFilesSelected = onFilesSelected,
       _accept = accept,
       _multiple = multiple,
       _maxSize = maxSize,
       _placeholder = placeholder {
    _tap = TapGestureRecognizer()..onTap = _handleTap;
  }

  void Function(List<String> files)? _onFilesSelected;
  set onFilesSelected(void Function(List<String> files)? value) =>
      _onFilesSelected = value;

  List<String>? _accept;
  set accept(List<String>? value) => _accept = value;

  // ignore: unused_field
  bool _multiple;
  set multiple(bool value) => _multiple = value;

  // ignore: unused_field
  int? _maxSize;
  set maxSize(int? value) => _maxSize = value;

  String _placeholder;
  set placeholder(String value) {
    if (_placeholder != value) {
      _placeholder = value;
      markNeedsPaint();
    }
  }

  late TapGestureRecognizer _tap;
  final bool _isDragOver = false;
  List<String> _selectedFiles = [];

  static const double _height = 120.0;

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    size = constraints.constrain(Size(constraints.maxWidth, _height));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final rect = offset & size;

    // Background
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      Paint()
        ..color = _isDragOver
            ? const Color(0xFFE3F2FD)
            : const Color(0xFFFAFAFA),
    );

    // Dashed border
    final borderPaint = Paint()
      ..color = _isDragOver ? const Color(0xFF2196F3) : const Color(0xFFCCCCCC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final dashPath = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)));
    canvas.drawPath(dashPath, borderPaint);

    // Icon
    textPainter.text = const TextSpan(
      text: '📁',
      style: TextStyle(fontSize: 32),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(rect.center.dx - textPainter.width / 2, offset.dy + 20),
    );

    // Text
    final displayText = _selectedFiles.isEmpty
        ? _placeholder
        : '${_selectedFiles.length} file(s) selected';
    textPainter.text = TextSpan(
      text: displayText,
      style: TextStyle(
        fontSize: 14,
        color: _selectedFiles.isEmpty
            ? const Color(0xFF666666)
            : const Color(0xFF333333),
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(rect.center.dx - textPainter.width / 2, offset.dy + 65),
    );

    // Accept types
    if (_accept != null && _accept!.isNotEmpty && _selectedFiles.isEmpty) {
      textPainter.text = TextSpan(
        text: 'Accepts: ${_accept!.join(", ")}',
        style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(rect.center.dx - textPainter.width / 2, offset.dy + 90),
      );
    }
  }

  void _handleTap() {
    // In a real implementation, this would open a file picker dialog
    // For now, simulate selection
    _selectedFiles = ['example_file.txt'];
    _onFilesSelected?.call(_selectedFiles);
    markNeedsPaint();
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _tap.addPointer(event);
    }
  }
}
