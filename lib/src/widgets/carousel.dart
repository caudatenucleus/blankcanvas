import 'package:flutter/widgets.dart';
import 'page_indicator.dart';

/// A horizontal carousel with swipeable pages and optional indicator.
class Carousel extends StatefulWidget {
  const Carousel({
    super.key,
    required this.children,
    this.showIndicator = true,
    this.onPageChanged,
    this.initialPage = 0,
    this.indicatorAlignment = Alignment.bottomCenter,
    this.indicatorPadding = const EdgeInsets.only(bottom: 16),
  });

  final List<Widget> children;
  final bool showIndicator;
  final ValueChanged<int>? onPageChanged;
  final int initialPage;
  final Alignment indicatorAlignment;
  final EdgeInsets indicatorPadding;

  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  late PageController _controller;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _controller = PageController(initialPage: widget.initialPage);
    _controller.addListener(_onPageScroll);
  }

  @override
  void dispose() {
    _controller.removeListener(_onPageScroll);
    _controller.dispose();
    super.dispose();
  }

  void _onPageScroll() {
    final int newPage = _controller.page?.round() ?? 0;
    if (newPage != _currentPage) {
      setState(() => _currentPage = newPage);
      widget.onPageChanged?.call(newPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView(controller: _controller, children: widget.children),
        if (widget.showIndicator && widget.children.length > 1)
          Positioned.fill(
            child: Align(
              alignment: widget.indicatorAlignment,
              child: Padding(
                padding: widget.indicatorPadding,
                child: PageIndicator(
                  count: widget.children.length,
                  currentIndex: _currentPage,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
