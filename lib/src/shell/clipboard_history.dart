// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Manager for application clipboard history.
class ClipboardHistoryManager extends ChangeNotifier {
  final List<ClipboardEntry> _history = [];
  final int maxEntries;

  ClipboardHistoryManager({this.maxEntries = 50});

  List<ClipboardEntry> get history => List.unmodifiable(_history);

  Future<void> copy(String text, {String? source}) async {
    await Clipboard.setData(ClipboardData(text: text));
    _addEntry(
      ClipboardEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: text,
        timestamp: DateTime.now(),
        source: source,
      ),
    );
  }

  void _addEntry(ClipboardEntry entry) {
    _history.removeWhere((e) => e.content == entry.content);
    _history.insert(0, entry);
    while (_history.length > maxEntries) {
      _history.removeLast();
    }
    notifyListeners();
  }

  Future<void> paste(ClipboardEntry entry) async {
    await Clipboard.setData(ClipboardData(text: entry.content));
  }

  void remove(String id) {
    _history.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void clear() {
    _history.clear();
    notifyListeners();
  }
}

class ClipboardEntry {
  const ClipboardEntry({
    required this.id,
    required this.content,
    required this.timestamp,
    this.source,
  });

  final String id;
  final String content;
  final DateTime timestamp;
  final String? source;
}
