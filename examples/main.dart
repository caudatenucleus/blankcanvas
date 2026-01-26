import 'package:flutter/widgets.dart';
import 'package:blankcanvas/blankcanvas.dart';

import 'node_graph_demo.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: CanvasBox(
        decoration: const CanvasBoxDecoration(color: Color(0xFF111111)),
        child: const NodeGraphDemo(),
      ),
    );
  }
}
