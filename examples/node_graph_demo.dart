import 'package:flutter/widgets.dart';
import 'package:blankcanvas/blankcanvas.dart';
import 'package:blankcanvas/src/core/atoms/canvas_status.dart';

class NodeGraphDemo extends StatelessWidget {
  const NodeGraphDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return CanvasBox(
      decoration: const CanvasBoxDecoration(color: Color(0xFF1E1E1E)),
      child: CanvasStack(
        children: [
          // Background Grid?

          // Wire (Layer 0)
          Positioned.fill(
            child: CanvasBox(
              decoration: const WireDecoration(
                start: Offset(150, 100),
                end: Offset(400, 300),
              ),
            ),
          ),

          // Node A
          Positioned(
            left: 50,
            top: 50,
            child: NodeWidget(
              title: "Input Node",
              outputColor: Color(0xFF00FF00),
            ),
          ),

          // Node B
          Positioned(
            left: 400,
            top: 250,
            child: NodeWidget(
              title: "Process Node",
              inputColor: Color(0xFF00FF00),
            ),
          ),
        ],
      ),
    );
  }
}

class NodeWidget extends StatelessWidget {
  const NodeWidget({
    super.key,
    required this.title,
    this.inputColor,
    this.outputColor,
  });

  final String title;
  final Color? inputColor;
  final Color? outputColor;

  @override
  Widget build(BuildContext context) {
    return CanvasControl(
      onPressed: () {},
      child: CanvasBox(
        decoration: const CanvasBoxDecoration(
          color: Color(0xFF2D2D2D),
          borderRadius: 8.0,
        ),
        child: CanvasFlex(
          direction: Axis.vertical,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            CanvasBox(
              decoration: const CanvasBoxDecoration(
                color: Color(0xFF3D3D3D),
                borderRadius: 8.0,
              ), // Actually only top radius usually
              child: CanvasBox(
                decoration: const PaddingDecoration(
                  padding: EdgeInsets.all(8.0),
                ),
                child: CanvasText(
                  TextSpan(
                    text: title,
                    style: const TextStyle(color: Color(0xFFEEEEEE)),
                  ),
                ),
              ),
            ),

            // Body
            CanvasBox(
              decoration: const PaddingDecoration(
                padding: EdgeInsets.all(16.0),
              ),
              child: CanvasFlex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (inputColor != null) NodeSocket(color: inputColor!),
                  if (outputColor != null) NodeSocket(color: outputColor!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NodeSocket extends StatelessWidget {
  const NodeSocket({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return CanvasControl(
      cursor: SystemMouseCursors.grab,
      onHover: (hover) {},
      child: CanvasBox(
        width: 16,
        height: 16,
        decoration: CircleDecoration(color: color),
      ),
    );
  }
}

// Decorations

class CircleDecoration extends CanvasDecoration {
  const CircleDecoration({required this.color});
  final Color color;

  @override
  Path getClipPath(Size size) {
    return Path()..addOval(Offset.zero & size);
  }

  @override
  void paint(Canvas canvas, Size size, ControlStatus status) {
    final Paint paint = Paint()..color = color;
    if (status.isHovered) {
      paint.color = Color.lerp(color, const Color(0xFFFFFFFF), 0.5)!;
    }
    canvas.drawOval(Offset.zero & size, paint);
  }
}

class WireDecoration extends CanvasDecoration {
  const WireDecoration({required this.start, required this.end});
  final Offset start;
  final Offset end;

  @override
  Path getClipPath(Size size) => Path(); // No clip

  @override
  void paint(Canvas canvas, Size size, ControlStatus status) {
    final Paint paint = Paint()
      ..color = const Color(0xFF888888)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final Path path = Path();
    path.moveTo(start.dx, start.dy);
    path.cubicTo(start.dx + 50, start.dy, end.dx - 50, end.dy, end.dx, end.dy);

    canvas.drawPath(path, paint);
  }
}

class PaddingDecoration extends CanvasDecoration {
  const PaddingDecoration({required this.padding});

  @override
  final EdgeInsets padding;

  @override
  Path getClipPath(Size size) => Path()..addRect(Offset.zero & size);

  @override
  void paint(Canvas canvas, Size size, ControlStatus status) {
    // Transparent
  }
}
