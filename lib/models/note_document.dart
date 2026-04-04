import 'dart:collection';

import '../cherrytree/ct_body_plain.dart';
import '../rich/note_body_codec.dart';

class NoteNode {
  NoteNode({
    required this.id,
    required this.parentId,
    required this.title,
    required this.body,
    required this.sortIndex,
    this.customIconId = 0,
  });

  final String id;
  final String? parentId;
  String title;
  String body;
  int sortIndex;

  /// CherryTree stock icon index (see upstream `CtStockIcon` / `custom_icon_id` in XML / `is_ro` in SQLite).
  int customIconId;

  Map<String, dynamic> toJson() => {
        'id': id,
        'parentId': parentId,
        'title': title,
        'body': body,
        'sortIndex': sortIndex,
        'customIconId': customIconId,
      };

  factory NoteNode.fromJson(Map<String, dynamic> json) {
    final rawBody = json['body'] as String? ?? '';
    final body = NoteBodyCodec.looksLikeQuillDeltaJson(rawBody)
        ? rawBody
        : CtBodyPlain.normalizeSeparatedCheckboxLines(rawBody);
    return NoteNode(
      id: json['id'] as String,
      parentId: json['parentId'] as String?,
      title: json['title'] as String? ?? '',
      body: body,
      sortIndex: (json['sortIndex'] as num?)?.toInt() ?? 0,
      customIconId: (json['customIconId'] as num?)?.toInt() ?? 0,
    );
  }
}

class NoteDocument {
  NoteDocument({List<NoteNode>? nodes}) : nodes = nodes ?? [];

  final List<NoteNode> nodes;

  List<NoteNode> childrenOf(String? parentId) {
    final list = nodes.where((n) => n.parentId == parentId).toList()
      ..sort((a, b) => a.sortIndex.compareTo(b.sortIndex));
    return list;
  }

  NoteNode? find(String id) {
    for (final n in nodes) {
      if (n.id == id) return n;
    }
    return null;
  }

  /// Nodes from the root down to [id] inclusive. Empty if [id] is missing.
  List<NoteNode> pathFromRoot(String id) {
    final upwards = <NoteNode>[];
    String? cur = id;
    while (cur != null) {
      final n = find(cur);
      if (n == null) return [];
      upwards.add(n);
      cur = n.parentId;
    }
    return upwards.reversed.toList();
  }

  void removeSubtree(String id) {
    final toRemove = _collectDescendantIds(id);
    nodes.removeWhere((n) => toRemove.contains(n.id));
  }

  HashSet<String> _collectDescendantIds(String rootId) {
    final result = HashSet<String>()..add(rootId);
    void walk(String pid) {
      for (final n in nodes.where((n) => n.parentId == pid)) {
        result.add(n.id);
        walk(n.id);
      }
    }

    walk(rootId);
    return result;
  }

  int nextSortIndex(String? parentId) {
    final siblings = childrenOf(parentId);
    if (siblings.isEmpty) return 0;
    return siblings.map((n) => n.sortIndex).reduce((a, b) => a > b ? a : b) + 1;
  }

  Map<String, dynamic> toJson() => {
        'nodes': nodes.map((n) => n.toJson()).toList(),
      };

  factory NoteDocument.fromJson(Map<String, dynamic> json) {
    final raw = json['nodes'] as List<dynamic>? ?? [];
    return NoteDocument(
      nodes: raw
          .map((e) => NoteNode.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}
