// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Monitor for system CPU and RAM usage.
class SystemPerformanceMonitor extends ChangeNotifier {
  double _cpuUsage = 0.0;
  double _memoryUsage = 0.0;
  double _totalMemory = 0.0;
  double _usedMemory = 0.0;
  Timer? _pollingTimer;

  static const MethodChannel _channel = MethodChannel(
    'blankcanvas/system_performance',
  );

  double get cpuUsage => _cpuUsage;
  double get memoryUsage => _memoryUsage;
  double get totalMemory => _totalMemory;
  double get usedMemory => _usedMemory;

  void startMonitoring({Duration interval = const Duration(seconds: 2)}) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(interval, (_) => _fetchStats());
    _fetchStats();
  }

  void stopMonitoring() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _fetchStats() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'getStats',
      );
      if (result != null) {
        _cpuUsage = (result['cpuUsage'] as num?)?.toDouble() ?? 0.0;
        _memoryUsage = (result['memoryUsage'] as num?)?.toDouble() ?? 0.0;
        _totalMemory = (result['totalMemory'] as num?)?.toDouble() ?? 0.0;
        _usedMemory = (result['usedMemory'] as num?)?.toDouble() ?? 0.0;
        notifyListeners();
      }
    } on PlatformException catch (e) {
      debugPrint('SystemPerformance getStats failed: $e');
    }
  }

  @override
  void dispose() {
    stopMonitoring();
    super.dispose();
  }
}

/// A widget that displays system performance metrics using lowest-level RenderObject APIs.
class SystemPerformanceWidget extends LeafRenderObjectWidget {
  const SystemPerformanceWidget({
    super.key,
    required this.monitor,
    this.showCpu = true,
    this.showMemory = true,
  });

  final SystemPerformanceMonitor monitor;
  final bool showCpu;
  final bool showMemory;

  @override
  RenderSystemPerformance createRenderObject(BuildContext context) {
    return RenderSystemPerformance(
      monitor: monitor,
      showCpu: showCpu,
      showMemory: showMemory,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSystemPerformance renderObject,
  ) {
    renderObject
      ..monitor = monitor
      ..showCpu = showCpu
      ..showMemory = showMemory;
  }
}

class RenderSystemPerformance extends RenderBox {
  RenderSystemPerformance({
    required SystemPerformanceMonitor monitor,
    required bool showCpu,
    required bool showMemory,
  }) : _monitor = monitor,
       _showCpu = showCpu,
       _showMemory = showMemory {
    _monitor.addListener(markNeedsPaint);
  }

  SystemPerformanceMonitor _monitor;
  SystemPerformanceMonitor get monitor => _monitor;
  set monitor(SystemPerformanceMonitor value) {
    if (_monitor == value) return;
    _monitor.removeListener(markNeedsPaint);
    _monitor = value;
    _monitor.addListener(markNeedsPaint);
    markNeedsPaint();
  }

  bool _showCpu;
  bool get showCpu => _showCpu;
  set showCpu(bool value) {
    if (_showCpu == value) return;
    _showCpu = value;
    markNeedsLayout();
    markNeedsPaint();
  }

  bool _showMemory;
  bool get showMemory => _showMemory;
  set showMemory(bool value) {
    if (_showMemory == value) return;
    _showMemory = value;
    markNeedsLayout();
    markNeedsPaint();
  }

  @override
  void detach() {
    _monitor.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  void performLayout() {
    size = constraints.constrain(const Size(120, 20));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final double cpuUsage = _monitor.cpuUsage;
    final double memUsage = _monitor.memoryUsage;

    if (_showCpu) {
      _paintIndicator(canvas, offset, cpuUsage, 'CPU');
    }
    if (_showMemory) {
      _paintIndicator(canvas, offset + const Offset(60, 0), memUsage, 'RAM');
    }
  }

  void _paintIndicator(
    Canvas canvas,
    Offset offset,
    double value,
    String label,
  ) {
    final paint = Paint()..color = _getColor(value);
    canvas.drawRect(offset & const Size(50, 16), paint);
  }

  Color _getColor(double value) {
    if (value < 0.5) return const Color(0xFF4CAF50);
    if (value < 0.8) return const Color(0xFFFFC107);
    return const Color(0xFFF44336);
  }
}
