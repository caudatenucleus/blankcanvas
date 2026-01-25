import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

/// A voice input widget with recording indicator.
class VoiceInput extends LeafRenderObjectWidget {
  const VoiceInput({
    super.key,
    this.onTranscription,
    this.onRecordingChanged,
    this.placeholder = 'Tap to speak...',
    this.tag,
  });

  final void Function(String text)? onTranscription;
  final void Function(bool isRecording)? onRecordingChanged;
  final String placeholder;
  final String? tag;

  @override
  RenderVoiceInput createRenderObject(BuildContext context) {
    return RenderVoiceInput(
      onTranscription: onTranscription,
      onRecordingChanged: onRecordingChanged,
      placeholder: placeholder,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderVoiceInput renderObject) {
    renderObject
      ..onTranscription = onTranscription
      ..onRecordingChanged = onRecordingChanged
      ..placeholder = placeholder;
  }
}

class RenderVoiceInput extends RenderBox {
  RenderVoiceInput({
    void Function(String text)? onTranscription,
    void Function(bool isRecording)? onRecordingChanged,
    required String placeholder,
  }) : _onTranscription = onTranscription,
       _onRecordingChanged = onRecordingChanged,
       _placeholder = placeholder {
    _tap = TapGestureRecognizer()..onTap = _handleTap;
  }

  void Function(String text)? _onTranscription;
  set onTranscription(void Function(String text)? value) =>
      _onTranscription = value;

  void Function(bool isRecording)? _onRecordingChanged;
  set onRecordingChanged(void Function(bool isRecording)? value) =>
      _onRecordingChanged = value;

  String _placeholder;
  set placeholder(String value) {
    if (_placeholder != value) {
      _placeholder = value;
      markNeedsPaint();
    }
  }

  late TapGestureRecognizer _tap;
  bool _isRecording = false;
  bool _isHovered = false;
  String _transcription = '';

  static const double _buttonSize = 64.0;
  static const double _height = 100.0;

  Rect _buttonRect = Rect.zero;

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    size = constraints.constrain(Size(constraints.maxWidth, _height));
    _buttonRect = Rect.fromCircle(
      center: Offset(size.width / 2, _height / 2),
      radius: _buttonSize / 2,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final center = offset + Offset(size.width / 2, _height / 2);

    // Recording pulse animation (static for now)
    if (_isRecording) {
      for (int i = 2; i >= 0; i--) {
        final opacity = 0.1 + i * 0.1;
        final radius = _buttonSize / 2 + 8 + i * 8;
        canvas.drawCircle(
          center,
          radius,
          Paint()..color = const Color(0xFFE53935).withValues(alpha: opacity),
        );
      }
    }

    // Main button
    canvas.drawCircle(
      center,
      _buttonSize / 2,
      Paint()
        ..color = _isRecording
            ? const Color(0xFFE53935)
            : (_isHovered ? const Color(0xFF1976D2) : const Color(0xFF2196F3)),
    );

    // Microphone icon
    textPainter.text = TextSpan(
      text: _isRecording ? '⏹' : '🎤',
      style: const TextStyle(fontSize: 28, color: Color(0xFFFFFFFF)),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );

    // Status text
    textPainter.text = TextSpan(
      text: _isRecording
          ? 'Recording...'
          : (_transcription.isEmpty ? _placeholder : _transcription),
      style: TextStyle(
        fontSize: 12,
        color: _isRecording ? const Color(0xFFE53935) : const Color(0xFF666666),
      ),
    );
    textPainter.layout(maxWidth: size.width - 20);
    textPainter.paint(canvas, Offset(offset.dx + 10, offset.dy + _height - 16));
  }

  void _handleTap() {
    _isRecording = !_isRecording;
    _onRecordingChanged?.call(_isRecording);

    if (!_isRecording && _transcription.isEmpty) {
      // Simulate transcription
      _transcription = 'Sample transcribed text';
      _onTranscription?.call(_transcription);
    }
    markNeedsPaint();
  }

  void _handleHover(PointerHoverEvent event) {
    final isHovered = _buttonRect.contains(event.localPosition);
    if (_isHovered != isHovered) {
      _isHovered = isHovered;
      markNeedsPaint();
    }
  }

  @override
  bool hitTestSelf(Offset position) => _buttonRect.contains(position);

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _tap.addPointer(event);
    } else if (event is PointerHoverEvent) {
      _handleHover(event);
    }
  }
}
