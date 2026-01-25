// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'transfer.dart';
import 'transfer_layout.dart';
import 'transfer_list.dart';
import 'transfer_controls.dart';


class TransferState<T> extends State<Transfer<T>> {
  late List<T> _source;
  late List<T> _target;
  final Set<int> _sourceSelected = {};
  final Set<int> _targetSelected = {};

  @override
  void initState() {
    super.initState();
    _source = List.from(widget.sourceItems);
    _target = List.from(widget.targetItems);
  }

  void _moveToTarget() {
    final toMove = _sourceSelected.map((i) => _source[i]).toList();
    setState(() {
      _target.addAll(toMove);
      _source.removeWhere((item) => toMove.contains(item));
      _sourceSelected.clear();
    });
    widget.onChanged(_source, _target);
  }

  void _moveToSource() {
    final toMove = _targetSelected.map((i) => _target[i]).toList();
    setState(() {
      _source.addAll(toMove);
      _target.removeWhere((item) => toMove.contains(item));
      _targetSelected.clear();
    });
    widget.onChanged(_source, _target);
  }

  void _moveAllToTarget() {
    setState(() {
      _target.addAll(_source);
      _source.clear();
      _sourceSelected.clear();
    });
    widget.onChanged(_source, _target);
  }

  void _moveAllToSource() {
    setState(() {
      _source.addAll(_target);
      _target.clear();
      _targetSelected.clear();
    });
    widget.onChanged(_source, _target);
  }

  void _onSourceSelectionChange(Set<int> indices) {
    setState(() {
      _sourceSelected.clear();
      _sourceSelected.addAll(indices);
    });
  }

  void _onTargetSelectionChange(Set<int> indices) {
    setState(() {
      _targetSelected.clear();
      _targetSelected.addAll(indices);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TransferLayout(
      children: [
        TransferList(
          key: const ValueKey('Source'),
          title: widget.sourceTitle,
          items: _source,
          selectedIndices: _sourceSelected,
          onSelectionChanged: _onSourceSelectionChange,
        ),
        TransferControls(
          onToRight: _sourceSelected.isNotEmpty ? _moveToTarget : null,
          onAllToRight: _source.isNotEmpty ? _moveAllToTarget : null,
          onToLeft: _targetSelected.isNotEmpty ? _moveToSource : null,
          onAllToLeft: _target.isNotEmpty ? _moveAllToSource : null,
        ),
        TransferList(
          key: const ValueKey('Target'),
          title: widget.targetTitle,
          items: _target,
          selectedIndices: _targetSelected,
          onSelectionChanged: _onTargetSelectionChange,
        ),
      ],
    );
  }
}
