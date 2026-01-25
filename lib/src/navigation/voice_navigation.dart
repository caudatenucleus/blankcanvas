import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

/// A widget that listens for voice commands (simulated via keyboard shortcuts for now).
class VoiceNavigation extends SingleChildRenderObjectWidget {
  const VoiceNavigation({
    super.key,
    required Widget child,
    this.onCommand,
    this.isListening = true,
    this.tag,
  }) : super(child: child);

  final ValueChanged<String>? onCommand;
  final bool isListening;
  final String? tag;

  @override
  RenderVoiceNavigation createRenderObject(BuildContext context) {
    return RenderVoiceNavigation(
      onCommand: onCommand,
      isListening: isListening,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderVoiceNavigation renderObject,
  ) {
    renderObject
      ..onCommand = onCommand
      ..isListening = isListening;
  }
}

class RenderVoiceNavigation extends RenderProxyBox {
  RenderVoiceNavigation({
    ValueChanged<String>? onCommand,
    bool isListening = true,
  }) : _onCommand = onCommand,
       _isListening = isListening;

  ValueChanged<String>? _onCommand;
  set onCommand(ValueChanged<String>? value) => _onCommand = value;

  bool _isListening;
  set isListening(bool value) => _isListening = value;

  // In a real implementation, this would interface with a plugin.
  // Here we can attach a keyboard listener to simulate "commands"
  // e.g. pressing 'V' then typing command.

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  @override
  void detach() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    super.detach();
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (!_isListening) return false;

    // Simulate "Back" command with 'B' Key
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.keyB) {
        _onCommand?.call('Back');
        return true;
      }
      if (event.logicalKey == LogicalKeyboardKey.keyH) {
        _onCommand?.call('Home');
        return true;
      }
    }
    return false;
  }
}
