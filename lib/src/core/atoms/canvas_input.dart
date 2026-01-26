import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class CanvasInput extends LeafRenderObjectWidget {
  const CanvasInput({
    super.key,
    required this.text,
    required this.startHandleLayerLink,
    required this.endHandleLayerLink,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.locale,
    this.textScaler = TextScaler.noScaling,
    this.maxLines = 1,
    this.minLines,
    this.selectionColor,
    this.color,
    this.cursorColor,
    this.showCursor,
    this.obscureText = false,
    this.offset,
    this.selection,
  });

  final InlineSpan text;
  final LayerLink startHandleLayerLink;
  final LayerLink endHandleLayerLink;
  final TextAlign textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final TextScaler textScaler;
  final int? maxLines;
  final int? minLines;
  final Color? selectionColor;
  final Color? color;
  final Color? cursorColor;
  final ValueNotifier<bool>? showCursor;
  final bool obscureText;
  final ViewportOffset? offset;
  final TextSelection? selection;

  @override
  RenderEditable createRenderObject(BuildContext context) {
    return RenderEditable(
      text: text,
      startHandleLayerLink: startHandleLayerLink,
      endHandleLayerLink: endHandleLayerLink,
      textAlign: textAlign,
      textDirection: textDirection ?? Directionality.of(context),
      locale: locale,
      textScaler: textScaler,
      maxLines: maxLines,
      minLines: minLines,
      selectionColor: selectionColor,
      cursorColor: cursorColor,
      showCursor: showCursor ?? ValueNotifier<bool>(false),
      obscureText: obscureText,
      offset: offset ?? ViewportOffset.zero(),
      selection: selection,
      textSelectionDelegate: _SimpleTextSelectionDelegate(),
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderEditable renderObject) {
    renderObject
      ..text = text
      ..startHandleLayerLink = startHandleLayerLink
      ..endHandleLayerLink = endHandleLayerLink
      ..textAlign = textAlign
      ..textDirection = textDirection ?? Directionality.of(context)
      ..locale = locale
      ..textScaler = textScaler
      ..maxLines = maxLines
      ..minLines = minLines
      ..selectionColor = selectionColor
      ..cursorColor = cursorColor
      ..showCursor = showCursor ?? ValueNotifier<bool>(false)
      ..obscureText = obscureText
      ..offset = offset ?? ViewportOffset.zero()
      ..selection = selection;
  }
}

class _SimpleTextSelectionDelegate with TextSelectionDelegate {
  @override
  TextEditingValue get textEditingValue => TextEditingValue.empty;

  set textEditingValue(TextEditingValue value) {}

  @override
  void hideToolbar([bool hideHandles = true]) {}

  @override
  void userUpdateTextEditingValue(
    TextEditingValue value,
    SelectionChangedCause cause,
  ) {}

  @override
  void bringIntoView(TextPosition position) {}

  @override
  void cutSelection(SelectionChangedCause cause) {}

  @override
  void copySelection(SelectionChangedCause cause) {}

  @override
  Future<void> pasteText(SelectionChangedCause cause) async {}

  @override
  void selectAll(SelectionChangedCause cause) {}

  @override
  bool get copyEnabled => true;

  @override
  bool get cutEnabled => true;

  @override
  bool get pasteEnabled => true;

  @override
  bool get selectAllEnabled => true;

  @override
  bool get lookUpEnabled => false;

  @override
  bool get searchWebEnabled => false;

  @override
  bool get shareEnabled => false;

  @override
  bool get liveTextInputEnabled => false;
}
