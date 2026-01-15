import 'package:flutter/widgets.dart';

/// Duration presets for notifications.
enum NotificationDuration { short, medium, long }

/// Shows a temporary notification popup (toast/snackbar equivalent).
class NotificationPopup {
  NotificationPopup._();

  static OverlayEntry? _currentEntry;

  /// Shows a notification popup with the given [child].
  static void show(
    BuildContext context, {
    required Widget child,
    NotificationDuration duration = NotificationDuration.medium,
    Alignment alignment = Alignment.bottomCenter,
  }) {
    // Dismiss any existing notification.
    _currentEntry?.remove();

    final overlay = Overlay.of(context);
    final durationMs = switch (duration) {
      NotificationDuration.short => 1500,
      NotificationDuration.medium => 3000,
      NotificationDuration.long => 5000,
    };

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _NotificationOverlay(
        alignment: alignment,
        onDismiss: () => entry.remove(),
        durationMs: durationMs,
        child: child,
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);
  }

  /// Dismisses the current notification if any.
  static void dismiss() {
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

class _NotificationOverlay extends StatefulWidget {
  const _NotificationOverlay({
    required this.alignment,
    required this.child,
    required this.onDismiss,
    required this.durationMs,
  });

  final Alignment alignment;
  final Widget child;
  final VoidCallback onDismiss;
  final int durationMs;

  @override
  State<_NotificationOverlay> createState() => _NotificationOverlayState();
}

class _NotificationOverlayState extends State<_NotificationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _controller.forward();

    Future.delayed(Duration(milliseconds: widget.durationMs), () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: false,
        child: Align(
          alignment: widget.alignment,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FadeTransition(
              opacity: _controller,
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _controller,
                        curve: Curves.easeOut,
                      ),
                    ),
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: Color(0xFF323232),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x44000000),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: DefaultTextStyle(
                      style: const TextStyle(color: Color(0xFFFFFFFF)),
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
