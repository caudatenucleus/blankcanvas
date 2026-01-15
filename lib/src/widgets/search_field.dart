import 'package:flutter/widgets.dart';

import 'text_field.dart' as bc;
import 'button.dart' as bc_button;
import 'layout.dart';

/// A search field with clear and search action buttons.
class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    this.controller,
    this.placeholder = 'Search...',
    this.onChanged,
    this.onSearchPressed,
    this.tag,
  });

  final TextEditingController? controller;
  final String placeholder;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSearchPressed;
  final String? tag;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late TextEditingController _controller;
  bool _showClear = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
    _showClear = _controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    widget.onChanged?.call(_controller.text);
    final shouldShowClear = _controller.text.isNotEmpty;
    if (shouldShowClear != _showClear) {
      setState(() => _showClear = shouldShowClear);
    }
  }

  void _clearText() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return FlexBox(
      direction: Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 8,
      children: [
        Expanded(
          child: bc.TextField(
            controller: _controller,
            placeholder: widget.placeholder,
            tag: widget.tag,
          ),
        ),
        if (_showClear)
          bc_button.Button(
            onPressed: _clearText,
            tag: 'icon',
            child: const Text('✕', style: TextStyle(fontSize: 18)),
          ),
        bc_button.Button(
          onPressed: widget.onSearchPressed,
          tag: 'primary',
          child: const Text('🔍', style: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }
}
