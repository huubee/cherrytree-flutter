import '../models/note_document.dart';

/// Maps [NoteNode.id] strings to CherryTree integer node ids (`ct-*` or new ids).
class CherrytreeIdMap {
  CherrytreeIdMap._(this._map);

  final Map<String, int> _map;

  /// Parses `ct-123` → `123`; returns null for non-`ct` ids (e.g. UUIDs).
  static int? parseCtId(String id) {
    if (!id.startsWith('ct-')) return null;
    return int.tryParse(id.substring(3));
  }

  factory CherrytreeIdMap.fromDocument(NoteDocument doc) {
    var maxCt = 0;
    for (final n in doc.nodes) {
      final v = parseCtId(n.id);
      if (v != null && v > maxCt) maxCt = v;
    }
    var next = maxCt + 1;
    final map = <String, int>{};
    for (final n in doc.nodes) {
      final v = parseCtId(n.id);
      if (v != null) {
        map[n.id] = v;
      } else {
        map[n.id] = next++;
      }
    }
    return CherrytreeIdMap._(map);
  }

  int operator [](String nodeId) => _map[nodeId]!;
}
