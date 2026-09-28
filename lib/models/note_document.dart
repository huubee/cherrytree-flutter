import 'dart:collection';

import '../cherrytree/ct_body_plain.dart';
import '../cherrytree/ct_constants.dart';
import '../rich/note_body_codec.dart';

class NoteNode {
  NoteNode({
    required this.id,
    required this.parentId,
    required this.title,
    required this.body,
    required this.sortIndex,
    this.customIconId = 0,
    this.tags = '',
    this.syntax = kCherrytreeRichTextSyntaxId,
    this.isBold = false,
    this.foregroundColor,
    this.isReadOnly = false,
    this.excludeMeFromSearch = false,
    this.excludeChildrenFromSearch = false,
    this.tsCreation = 0,
    this.tsLastSave = 0,
    this.masterId = 0,
  });

  final String id;
  String? parentId;
  String title;
  String body;
  int sortIndex;

  /// CherryTree stock icon index (see upstream `CtStockIcon` / `custom_icon_id` in XML / `is_ro` in SQLite).
  int customIconId;

  /// Space- or comma-separated tags associated with this node.
  String tags;

  /// Upstream syntax: `custom-colors` (rich text), `plain-text`, or language ID (`python`, `sh`, etc.).
  String syntax;

  /// Whether the node title in the tree view is rendered bold.
  bool isBold;

  /// Custom foreground color for node title in tree view (`#RRGGBB` or null).
  String? foregroundColor;

  /// Whether the node is protected against editing.
  bool isReadOnly;

  /// Exclude this node content/name from search queries.
  bool excludeMeFromSearch;

  /// Exclude child subnodes from search queries.
  bool excludeChildrenFromSearch;

  /// Creation timestamp (Unix epoch in seconds).
  int tsCreation;

  /// Last save timestamp (Unix epoch in seconds).
  int tsLastSave;

  /// Master node ID for shared/linked clone nodes (0 if normal node).
  int masterId;

  Map<String, dynamic> toJson() => {
        'id': id,
        'parentId': parentId,
        'title': title,
        'body': body,
        'sortIndex': sortIndex,
        'customIconId': customIconId,
        'tags': tags,
        'syntax': syntax,
        'isBold': isBold,
        'foregroundColor': foregroundColor,
        'isReadOnly': isReadOnly,
        'excludeMeFromSearch': excludeMeFromSearch,
        'excludeChildrenFromSearch': excludeChildrenFromSearch,
        'tsCreation': tsCreation,
        'tsLastSave': tsLastSave,
        'masterId': masterId,
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
      tags: json['tags'] as String? ?? '',
      syntax: json['syntax'] as String? ?? kCherrytreeRichTextSyntaxId,
      isBold: json['isBold'] as bool? ?? false,
      foregroundColor: json['foregroundColor'] as String?,
      isReadOnly: json['isReadOnly'] as bool? ?? false,
      excludeMeFromSearch: json['excludeMeFromSearch'] as bool? ?? false,
      excludeChildrenFromSearch:
          json['excludeChildrenFromSearch'] as bool? ?? false,
      tsCreation: (json['tsCreation'] as num?)?.toInt() ?? 0,
      tsLastSave: (json['tsLastSave'] as num?)?.toInt() ?? 0,
      masterId: (json['masterId'] as num?)?.toInt() ?? 0,
    );
  }
}

class NoteDocument {
  NoteDocument({
    List<NoteNode>? nodes,
    List<String>? bookmarks,
  })  : nodes = nodes ?? [],
        bookmarks = bookmarks ?? [];

  final List<NoteNode> nodes;

  /// Ordered list of bookmarked node ids.
  final List<String> bookmarks;

  bool isBookmarked(String id) => bookmarks.contains(id);

  void toggleBookmark(String id) {
    if (bookmarks.contains(id)) {
      bookmarks.remove(id);
    } else {
      bookmarks.add(id);
    }
  }

  void addBookmark(String id) {
    if (!bookmarks.contains(id)) {
      bookmarks.add(id);
    }
  }

  void removeBookmark(String id) {
    bookmarks.remove(id);
  }

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
    bookmarks.removeWhere((bId) => toRemove.contains(bId));
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

  bool moveNodeUp(String id) {
    final n = find(id);
    if (n == null) return false;
    final siblings = childrenOf(n.parentId);
    final idx = siblings.indexWhere((s) => s.id == id);
    if (idx <= 0) return false;
    final prev = siblings[idx - 1];
    _normalizeSiblingSortIndices(siblings);
    final temp = n.sortIndex;
    n.sortIndex = prev.sortIndex;
    prev.sortIndex = temp;
    return true;
  }

  bool moveNodeDown(String id) {
    final n = find(id);
    if (n == null) return false;
    final siblings = childrenOf(n.parentId);
    final idx = siblings.indexWhere((s) => s.id == id);
    if (idx < 0 || idx >= siblings.length - 1) return false;
    final next = siblings[idx + 1];
    _normalizeSiblingSortIndices(siblings);
    final temp = n.sortIndex;
    n.sortIndex = next.sortIndex;
    next.sortIndex = temp;
    return true;
  }

  void _normalizeSiblingSortIndices(List<NoteNode> siblings) {
    for (var i = 0; i < siblings.length; i++) {
      siblings[i].sortIndex = i;
    }
  }

  bool indentNode(String id) {
    final n = find(id);
    if (n == null) return false;
    final siblings = childrenOf(n.parentId);
    final idx = siblings.indexWhere((s) => s.id == id);
    if (idx <= 0) return false;
    final prev = siblings[idx - 1];
    n.parentId = prev.id;
    n.sortIndex = nextSortIndex(prev.id);
    return true;
  }

  bool unindentNode(String id) {
    final n = find(id);
    if (n == null || n.parentId == null) return false;
    final parent = find(n.parentId!);
    if (parent == null) return false;
    final parentSiblings = childrenOf(parent.parentId);
    final parentIdx = parentSiblings.indexWhere((s) => s.id == parent.id);
    n.parentId = parent.parentId;
    parentSiblings.removeWhere((s) => s.id == id);
    final insertIdx = parentIdx >= 0 ? parentIdx + 1 : parentSiblings.length;
    parentSiblings.insert(insertIdx, n);
    _normalizeSiblingSortIndices(parentSiblings);
    return true;
  }

  void insertSiblingAfter(String targetId, NoteNode newNode) {
    final target = find(targetId);
    if (target == null) {
      nodes.add(newNode);
      return;
    }
    newNode.parentId = target.parentId;
    final siblings = childrenOf(target.parentId);
    final targetIdx = siblings.indexWhere((s) => s.id == targetId);
    nodes.add(newNode);
    final insertIdx = targetIdx >= 0 ? targetIdx + 1 : siblings.length;
    siblings.insert(insertIdx, newNode);
    _normalizeSiblingSortIndices(siblings);
  }

  void sortSiblings(String? parentId, {bool ascending = true}) {
    final siblings = childrenOf(parentId);
    siblings.sort((a, b) {
      final cmp = a.title.toLowerCase().compareTo(b.title.toLowerCase());
      return ascending ? cmp : -cmp;
    });
    _normalizeSiblingSortIndices(siblings);
  }

  String? duplicateNode(String id, {required String Function() newIdGenerator}) {
    final orig = find(id);
    if (orig == null) return null;
    final newRootId = newIdGenerator();
    final idMapping = <String, String>{id: newRootId};

    final descendants = _collectDescendantIds(id);
    for (final descId in descendants) {
      if (descId != id) {
        idMapping[descId] = newIdGenerator();
      }
    }

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final newNodes = <NoteNode>[];
    for (final descId in descendants) {
      final item = find(descId);
      if (item == null) continue;
      final newId = idMapping[descId]!;
      final newParentId = descId == id
          ? orig.parentId
          : idMapping[item.parentId];
      final newSort = descId == id
          ? nextSortIndex(orig.parentId)
          : item.sortIndex;
      newNodes.add(
        NoteNode(
          id: newId,
          parentId: newParentId,
          title: descId == id ? '${item.title} (Copy)' : item.title,
          body: item.body,
          sortIndex: newSort,
          customIconId: item.customIconId,
          tags: item.tags,
          syntax: item.syntax,
          isBold: item.isBold,
          foregroundColor: item.foregroundColor,
          isReadOnly: item.isReadOnly,
          excludeMeFromSearch: item.excludeMeFromSearch,
          excludeChildrenFromSearch: item.excludeChildrenFromSearch,
          tsCreation: now,
          tsLastSave: now,
          masterId: 0,
        ),
      );
    }
    nodes.addAll(newNodes);
    return newRootId;
  }

  Map<String, dynamic> toJson() => {
        'nodes': nodes.map((n) => n.toJson()).toList(),
        'bookmarks': bookmarks,
      };

  factory NoteDocument.fromJson(Map<String, dynamic> json) {
    final raw = json['nodes'] as List<dynamic>? ?? [];
    final rawBm = json['bookmarks'] as List<dynamic>? ?? [];
    return NoteDocument(
      nodes: raw
          .map((e) => NoteNode.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      bookmarks: rawBm.map((e) => e.toString()).toList(),
    );
  }
}
