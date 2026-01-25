import 'dart:io' show Platform;
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';

/// Enum for supported platforms.
enum TargetPlatform { linux, macos, windows, android, ios, fuchsia, web }

/// Provides platform-specific behavior adaptation.
/// Uses lowest-level `dart:io` Platform and `kIsWeb`.
class PlatformAdapter {
  static TargetPlatform get currentPlatform {
    if (kIsWeb) return TargetPlatform.web;
    if (Platform.isLinux) return TargetPlatform.linux;
    if (Platform.isMacOS) return TargetPlatform.macos;
    if (Platform.isWindows) return TargetPlatform.windows;
    if (Platform.isAndroid) return TargetPlatform.android;
    if (Platform.isIOS) return TargetPlatform.ios;
    if (Platform.isFuchsia) return TargetPlatform.fuchsia;
    return TargetPlatform.linux; // Fallback
  }

  static bool get isDesktop =>
      currentPlatform == TargetPlatform.linux ||
      currentPlatform == TargetPlatform.macos ||
      currentPlatform == TargetPlatform.windows;

  static bool get isMobile =>
      currentPlatform == TargetPlatform.android ||
      currentPlatform == TargetPlatform.ios;

  static bool get isWeb => currentPlatform == TargetPlatform.web;

  /// Selects a value based on platform.
  static T select<T>({required T desktop, required T mobile, T? web}) {
    if (isWeb) return web ?? desktop;
    if (isMobile) return mobile;
    return desktop;
  }
}

/// Low-level native view integration placeholder.
/// In real apps, this would wrap PlatformView or AndroidView/UiKitView.
/// Here we simulate the pattern using a LeafRenderObjectWidget.
class NativeBridgeUI extends LeafRenderObjectWidget {
  const NativeBridgeUI({
    super.key,
    required this.viewType,
    this.creationParams,
  });

  final String viewType;
  final Map<String, dynamic>? creationParams;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderNativeBridgeUI(viewType: viewType);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderNativeBridgeUI renderObject,
  ) {
    renderObject.viewType = viewType;
  }
}

class RenderNativeBridgeUI extends RenderBox {
  RenderNativeBridgeUI({required String viewType}) : _viewType = viewType;

  String _viewType;
  set viewType(String v) {
    if (_viewType != v) {
      _viewType = v;
      markNeedsPaint();
    }
  }

  @override
  void performLayout() {
    // Take all available space (simulating an embedded view)
    size = constraints.biggest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // In a real implementation, this would render the platform view.
    // Here, we paint a placeholder rectangle.
    context.canvas.drawRect(
      offset & size,
      Paint()..color = const Color(0xFF444444),
    );
  }
}
