import 'package:flutter/widgets.dart';

/// A sliver that creates a collapsible/expandable header.
class SliverHeader extends StatelessWidget {
  const SliverHeader({
    super.key,
    required this.expandedHeight,
    required this.collapsedHeight,
    required this.background,
    this.title,
    this.floating = false,
    this.pinned = true,
    this.backgroundColor,
  });

  final double expandedHeight;
  final double collapsedHeight;
  final Widget background;
  final Widget? title;
  final bool floating;
  final bool pinned;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: pinned,
      floating: floating,
      delegate: _SliverHeaderDelegate(
        expandedHeight: expandedHeight,
        collapsedHeight: collapsedHeight,
        background: background,
        title: title,
        backgroundColor: backgroundColor,
      ),
    );
  }
}

class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  _SliverHeaderDelegate({
    required this.expandedHeight,
    required this.collapsedHeight,
    required this.background,
    this.title,
    this.backgroundColor,
  });

  final double expandedHeight;
  final double collapsedHeight;
  final Widget background;
  final Widget? title;
  final Color? backgroundColor;

  @override
  double get minExtent => collapsedHeight;

  @override
  double get maxExtent => expandedHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final double progress = (shrinkOffset / (maxExtent - minExtent)).clamp(
      0.0,
      1.0,
    );
    final double backgroundOpacity = 1.0 - progress;
    final double titleOpacity = progress;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background (fades out as header collapses)
        Positioned.fill(
          child: Opacity(opacity: backgroundOpacity, child: background),
        ),
        // Collapsed background color
        if (backgroundColor != null)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color.from(
                  alpha: progress,
                  red: backgroundColor!.r,
                  green: backgroundColor!.g,
                  blue: backgroundColor!.b,
                ),
              ),
            ),
          ),

        // Title (fades in as header collapses)
        if (title != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: 12,
            child: Opacity(opacity: titleOpacity, child: title!),
          ),
      ],
    );
  }

  @override
  bool shouldRebuild(_SliverHeaderDelegate oldDelegate) {
    return expandedHeight != oldDelegate.expandedHeight ||
        collapsedHeight != oldDelegate.collapsedHeight ||
        background != oldDelegate.background ||
        title != oldDelegate.title ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}

/// A collapsible app bar style header for use in CustomScrollView.
class CollapsibleHeader extends StatelessWidget {
  const CollapsibleHeader({
    super.key,
    required this.expandedHeight,
    this.collapsedHeight = 56.0,
    required this.title,
    this.background,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.pinned = true,
    this.floating = false,
  });

  final double expandedHeight;
  final double collapsedHeight;
  final Widget title;
  final Widget? background;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool pinned;
  final bool floating;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: pinned,
      floating: floating,
      delegate: _CollapsibleHeaderDelegate(
        expandedHeight: expandedHeight,
        collapsedHeight: collapsedHeight,
        title: title,
        background: background,
        actions: actions,
        backgroundColor: backgroundColor ?? const Color(0xFF2196F3),
        foregroundColor: foregroundColor ?? const Color(0xFFFFFFFF),
      ),
    );
  }
}

class _CollapsibleHeaderDelegate extends SliverPersistentHeaderDelegate {
  _CollapsibleHeaderDelegate({
    required this.expandedHeight,
    required this.collapsedHeight,
    required this.title,
    this.background,
    this.actions,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final double expandedHeight;
  final double collapsedHeight;
  final Widget title;
  final Widget? background;
  final List<Widget>? actions;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  double get minExtent => collapsedHeight;

  @override
  double get maxExtent => expandedHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final double progress = (shrinkOffset / (maxExtent - minExtent)).clamp(
      0.0,
      1.0,
    );
    final double titleScale = 1.0 - (progress * 0.3); // Scale from 1.0 to 0.7
    final double titleLeftPadding =
        16 + (progress * 40); // Slide right as it shrinks

    return DecoratedBox(
      decoration: BoxDecoration(color: backgroundColor),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image/widget (fades out)
          if (background != null)
            Positioned.fill(
              child: Opacity(opacity: 1.0 - progress, child: background!),
            ),
          // Title
          Positioned(
            left: titleLeftPadding,
            right: 16 + ((actions?.length ?? 0) * 48),
            bottom: 8 + (progress * 8),
            child: Transform.scale(
              scale: titleScale,
              alignment: Alignment.bottomLeft,
              child: DefaultTextStyle(
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                child: title,
              ),
            ),
          ),
          // Actions
          if (actions != null && actions!.isNotEmpty)
            Positioned(right: 8, top: 8, child: Row(children: actions!)),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_CollapsibleHeaderDelegate oldDelegate) {
    return expandedHeight != oldDelegate.expandedHeight ||
        collapsedHeight != oldDelegate.collapsedHeight ||
        title != oldDelegate.title ||
        background != oldDelegate.background ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
