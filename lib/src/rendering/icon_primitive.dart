import 'package:flutter/widgets.dart';
import 'paragraph_primitive.dart';

/// A low-level icon renderer that avoids high-level widgets.
class IconPrimitive extends LeafRenderObjectWidget {
  const IconPrimitive({
    super.key,
    required this.icon,
    this.size = 24.0,
    this.color,
  });

  final IconData icon;
  final double size;
  final Color? color;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderParagraphPrimitive(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          inherit: false,
          color: color,
          fontSize: size,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
        ),
      ),
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderParagraphPrimitive renderObject,
  ) {
    renderObject.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        inherit: false,
        color: color,
        fontSize: size,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
      ),
    );
  }
}
