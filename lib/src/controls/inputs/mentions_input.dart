import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

/// A text field with @mention support.
class MentionsInput extends LeafRenderObjectWidget {
  const MentionsInput({
    super.key,
    required this.mentions,
    this.onMentionSelected,
    this.onChanged,
    this.mentionTrigger = '@',
    this.placeholder,
    this.tag,
  });

  final List<MentionItem> mentions;
  final void Function(MentionItem mention)? onMentionSelected;
  final ValueChanged<String>? onChanged;
  final String mentionTrigger;
  final String? placeholder;
  final String? tag;

  @override
  RenderMentionsInput createRenderObject(BuildContext context) {
    return RenderMentionsInput(
      mentions: mentions,
      onMentionSelected: onMentionSelected,
      onChanged: onChanged,
      mentionTrigger: mentionTrigger,
      placeholder: placeholder,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderMentionsInput renderObject,
  ) {
    renderObject
      ..mentions = mentions
      ..onMentionSelected = onMentionSelected
      ..onChanged = onChanged
      ..mentionTrigger = mentionTrigger
      ..placeholder = placeholder;
  }
}

class MentionItem {
  const MentionItem({required this.id, required this.display, this.avatar});

  final String id;
  final String display;
  final Widget? avatar;
}

class RenderMentionsInput extends RenderBox {
  RenderMentionsInput({
    required List<MentionItem> mentions,
    void Function(MentionItem mention)? onMentionSelected,
    ValueChanged<String>? onChanged,
    required String mentionTrigger,
    String? placeholder,
  }) : _mentions = mentions,
       _onMentionSelected = onMentionSelected,
       _onChanged = onChanged,
       _mentionTrigger = mentionTrigger,
       _placeholder = placeholder {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  List<MentionItem> _mentions;
  set mentions(List<MentionItem> value) {
    _mentions = value;
    markNeedsPaint();
  }

  void Function(MentionItem mention)? _onMentionSelected;
  set onMentionSelected(void Function(MentionItem mention)? value) =>
      _onMentionSelected = value;

  ValueChanged<String>? _onChanged;
  set onChanged(ValueChanged<String>? value) => _onChanged = value;

  String _mentionTrigger;
  set mentionTrigger(String value) => _mentionTrigger = value;

  String? _placeholder;
  set placeholder(String? value) {
    _placeholder = value;
    markNeedsPaint();
  }

  late TapGestureRecognizer _tap;
  String _text = '';
  bool _showingSuggestions = false;
  final List<MentionItem> _filteredMentions = [];
  int? _hoveredSuggestion;

  static const double _inputHeight = 40.0;
  static const double _suggestionHeight = 36.0;

  final List<Rect> _suggestionRects = [];

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    _suggestionRects.clear();
    double height = _inputHeight;
    if (_showingSuggestions) {
      for (int i = 0; i < _filteredMentions.length; i++) {
        _suggestionRects.add(
          Rect.fromLTWH(0, height, size.width, _suggestionHeight),
        );
        height += _suggestionHeight;
      }
    }
    size = constraints.constrain(Size(constraints.maxWidth, height));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    // Input field
    final inputRect = Rect.fromLTWH(
      offset.dx,
      offset.dy,
      size.width,
      _inputHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(inputRect, const Radius.circular(4)),
      Paint()
        ..color = const Color(0xFFE0E0E0)
        ..style = PaintingStyle.stroke,
    );

    // Text
    final textPainter = TextPainter(
      text: TextSpan(
        text: _text.isEmpty ? (_placeholder ?? 'Type @ to mention...') : _text,
        style: TextStyle(
          fontSize: 14,
          color: _text.isEmpty
              ? const Color(0xFF999999)
              : const Color(0xFF000000),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 24);
    textPainter.paint(
      canvas,
      Offset(
        offset.dx + 12,
        offset.dy + (_inputHeight - textPainter.height) / 2,
      ),
    );

    // Suggestions dropdown
    if (_showingSuggestions && _filteredMentions.isNotEmpty) {
      final dropdownRect = Rect.fromLTWH(
        offset.dx,
        offset.dy + _inputHeight,
        size.width,
        _filteredMentions.length * _suggestionHeight,
      );

      // Shadow and background
      final shadowPath = Path()
        ..addRRect(
          RRect.fromRectAndRadius(dropdownRect, const Radius.circular(4)),
        );
      canvas.drawShadow(shadowPath, const Color(0xFF000000), 8, false);
      canvas.drawRRect(
        RRect.fromRectAndRadius(dropdownRect, const Radius.circular(4)),
        Paint()..color = const Color(0xFFFFFFFF),
      );

      // Items
      for (int i = 0; i < _filteredMentions.length; i++) {
        if (i >= _suggestionRects.length) break;
        final itemRect = _suggestionRects[i].shift(offset);
        final mention = _filteredMentions[i];

        if (i == _hoveredSuggestion) {
          canvas.drawRect(itemRect, Paint()..color = const Color(0xFFF5F5F5));
        }

        textPainter.text = TextSpan(
          text: mention.display,
          style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            itemRect.left + 12,
            itemRect.center.dy - textPainter.height / 2,
          ),
        );
      }
    }
  }

  void _handleTapUp(TapUpDetails details) {
    final local = details.localPosition;

    if (_showingSuggestions) {
      for (int i = 0; i < _suggestionRects.length; i++) {
        if (_suggestionRects[i].contains(local)) {
          _selectMention(_filteredMentions[i]);
          return;
        }
      }
    }
  }

  void _selectMention(MentionItem mention) {
    _text = '$_mentionTrigger${mention.display} ';
    _showingSuggestions = false;
    _onMentionSelected?.call(mention);
    _onChanged?.call(_text);
    markNeedsLayout();
    markNeedsPaint();
  }

  void _handleHover(PointerHoverEvent event) {
    if (!_showingSuggestions) return;
    final local = event.localPosition;
    int? hovered;
    for (int i = 0; i < _suggestionRects.length; i++) {
      if (_suggestionRects[i].contains(local)) {
        hovered = i;
        break;
      }
    }
    if (_hoveredSuggestion != hovered) {
      _hoveredSuggestion = hovered;
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
