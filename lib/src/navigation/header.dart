import 'package:flutter/widgets.dart';
import 'toolbar.dart';

/// A static header (like AppBar) but as a simple container.
class Header extends Toolbar {
  Header({
    super.key,
    super.leading,
    Widget? title,
    super.actions,
    super.backgroundColor = const Color(0xFF2196F3),
    Color foregroundColor = const Color(0xFFFFFFFF),
    super.height = 56.0,
  }) : super(
         middle: title != null
             ? DefaultTextStyle(
                 style: TextStyle(
                   color: foregroundColor,
                   fontSize: 20,
                   fontWeight: FontWeight.w500,
                 ),
                 child: title,
               )
             : null,
       );
}
