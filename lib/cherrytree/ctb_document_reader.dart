import 'package:sqflite/sqflite.dart';

import '../models/note_document.dart';
import 'cherrytree_read_result.dart';
import 'ct_body_plain.dart';

/// Read-only import of an unencrypted CherryTree SQLite document ([.ctb]).
class CtbDocumentReader {
  CtbDocumentReader._();

  static Future<CherrytreeReadResult> readPath(String path) async {
    final w = <String>[];
    var anyEmbeddedWidgets = false;
    final db = await openDatabase(path, readOnly: true, singleInstance: true);
    try {
      await _ensureSchema(db);
      final nodes = <NoteNode>[];
      await _walk(
        db,
        fatherId: 0,
        parentId: null,
        nodes: nodes,
        warnings: w,
        onEmbeddedFlags: (code, table, image) {
          if (code || table || image) anyEmbeddedWidgets = true;
        },
      );
      if (anyEmbeddedWidgets) {
        w.add(
          'Some notes had embedded images, tables, or code boxes that are not shown in this import.',
        );
      }

      final bookmarks = <String>[];
      final bmTables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='bookmark'",
      );
      if (bmTables.isNotEmpty) {
        final bmRows = await db.rawQuery(
          'SELECT node_id FROM bookmark ORDER BY sequence ASC',
        );
        for (final row in bmRows) {
          final bmNodeId = _asInt(row['node_id']);
          if (bmNodeId != null) {
            bookmarks.add('ct-$bmNodeId');
          }
        }
      }

      return CherrytreeReadResult(
        document: NoteDocument(nodes: nodes, bookmarks: bookmarks),
        warnings: List<String>.from(w),
      );
    } finally {
      await db.close();
    }
  }

  static Future<void> _ensureSchema(Database db) async {
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name IN ('node','children')",
    );
    final names = tables.map((r) => r['name'] as String).toSet();
    if (!names.contains('node') || !names.contains('children')) {
      throw FormatException('Not a CherryTree SQLite document (missing node/children tables).');
    }
  }

  static Future<void> _walk(
    Database db, {
    required int fatherId,
    required String? parentId,
    required List<NoteNode> nodes,
    required List<String> warnings,
    required void Function(bool hasCodebox, bool hasTable, bool hasImage) onEmbeddedFlags,
  }) async {
    List<Map<String, Object?>> rows;
    try {
      rows = await db.rawQuery(
        'SELECT node_id, master_id FROM children WHERE father_id = ? ORDER BY sequence ASC',
        [fatherId],
      );
    } on Object {
      rows = await db.rawQuery(
        'SELECT node_id FROM children WHERE father_id = ? ORDER BY sequence ASC',
        [fatherId],
      );
    }

    var sortIndex = 0;
    for (final row in rows) {
      final nodeId = _asInt(row['node_id']);
      if (nodeId == null) continue;
      final masterId = _asInt(row['master_id']) ?? 0;

      final effectiveId = masterId > 0 ? masterId : nodeId;
      final nodeRow = await _fetchNodeRow(db, effectiveId);
      if (nodeRow == null) {
        warnings.add('Missing node row for id $effectiveId.');
        continue;
      }

      final name = nodeRow['name'] as String? ?? '';
      final txt = nodeRow['txt'] as String?;
      final syntax = nodeRow['syntax'] as String? ?? 'custom-colors';
      final tags = nodeRow['tags'] as String? ?? '';

      final isRoNum = _asInt(nodeRow['is_ro']) ?? 0;
      final isReadOnly = (isRoNum & 0x01) != 0;
      final customIconId = isRoNum >> 1;

      final isRichNum = _asInt(nodeRow['is_richtxt']) ?? 0;
      final isBold = ((isRichNum >> 1) & 0x01) != 0;
      final hasFg = ((isRichNum >> 2) & 0x01) != 0;
      String? foregroundColor;
      if (hasFg) {
        final rgb = (isRichNum >> 3) & 0xffffff;
        foregroundColor = '#${rgb.toRadixString(16).padLeft(6, '0')}';
      }

      final levelNum = _asInt(nodeRow['level']) ?? 0;
      final excludeMeFromSearch = (levelNum & 0x01) != 0;
      final excludeChildrenFromSearch = (levelNum & 0x02) != 0;

      final tsCreation = _asInt(nodeRow['ts_creation']) ?? 0;
      final tsLastSave = _asInt(nodeRow['ts_lastsave']) ?? 0;

      final hasCode = _truthy(nodeRow['has_codebox']);
      final hasTbl = _truthy(nodeRow['has_table']);
      final hasImg = _truthy(nodeRow['has_image']);
      onEmbeddedFlags(hasCode, hasTbl, hasImg);

      final body = CtBodyPlain.fromSqliteNode(
        txt: txt,
        syntax: syntax,
      );

      final id = 'ct-$nodeId';
      nodes.add(
        NoteNode(
          id: id,
          parentId: parentId,
          title: name,
          body: body,
          sortIndex: sortIndex++,
          customIconId: customIconId,
          tags: tags,
          syntax: syntax,
          isBold: isBold,
          foregroundColor: foregroundColor,
          isReadOnly: isReadOnly,
          excludeMeFromSearch: excludeMeFromSearch,
          excludeChildrenFromSearch: excludeChildrenFromSearch,
          tsCreation: tsCreation,
          tsLastSave: tsLastSave,
          masterId: masterId,
        ),
      );

      await _walk(
        db,
        fatherId: nodeId,
        parentId: id,
        nodes: nodes,
        warnings: warnings,
        onEmbeddedFlags: onEmbeddedFlags,
      );
    }
  }

  static Future<Map<String, Object?>?> _fetchNodeRow(Database db, int nodeId) async {
    final rows = await db.query('node', where: 'node_id = ?', whereArgs: [nodeId], limit: 1);
    if (rows.isEmpty) return null;
    return rows.first;
  }

  static int? _asInt(Object? v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  static bool _truthy(Object? v) {
    if (v == null) return false;
    if (v is bool) return v;
    if (v is int) return v != 0;
    return v == 1;
  }
}
