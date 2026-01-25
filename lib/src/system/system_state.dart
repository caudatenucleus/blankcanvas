import 'package:flutter/widgets.dart';
import '../rendering/paragraph_primitive.dart';

/// Abstract command pattern interface.
abstract class Command {
  void execute();
  void undo();
  String get name;
}

typedef UndoRedoManager = _UndoRedoManager;

class _UndoRedoManager extends ChangeNotifier {
  final List<Command> _undoStack = [];
  final List<Command> _redoStack = [];

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  void execute(Command command) {
    command.execute();
    _undoStack.add(command);
    _redoStack.clear();
    notifyListeners();
  }

  void undo() {
    if (canUndo) {
      final command = _undoStack.removeLast();
      command.undo();
      _redoStack.add(command);
      notifyListeners();
    }
  }

  void redo() {
    if (canRedo) {
      final command = _redoStack.removeLast();
      command.execute();
      _undoStack.add(command);
      notifyListeners();
    }
  }
}

/// A debug overlay to visualize system state using lowest-level RenderObject APIs.
class DebugInspector extends LeafRenderObjectWidget {
  const DebugInspector({super.key});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderParagraphPrimitive(
      text: const TextSpan(
        text: 'System State Inspector (Placeholder)',
        style: TextStyle(color: Color(0xFFFFFFFF)),
      ),
    );
  }
}
