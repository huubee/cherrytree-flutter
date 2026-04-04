import 'dart:convert';

import 'package:flutter_quill/flutter_quill.dart';

/// Persists note body as Quill Delta JSON, with backward compatibility for legacy plain text.
class NoteBodyCodec {
  NoteBodyCodec._();

  /// Detects stored Quill Delta JSON (array of ops with `insert` keys).
  static bool looksLikeQuillDeltaJson(String body) {
    final t = body.trimLeft();
    if (!t.startsWith('[')) return false;
    try {
      final decoded = jsonDecode(body);
      if (decoded is! List || decoded.isEmpty) return false;
      final first = decoded.first;
      return first is Map && first.containsKey('insert');
    } on Object {
      return false;
    }
  }

  /// Loads a [Document] from [body] storage (Quill JSON or legacy plain text).
  static Document documentFromStorage(String body) {
    if (looksLikeQuillDeltaJson(body)) {
      try {
        final list = jsonDecode(body) as List<dynamic>;
        return Document.fromJson(list);
      } on Object {
        // fall through to plain
      }
    }
    final t = body.isEmpty ? '\n' : (body.endsWith('\n') ? body : '$body\n');
    return Document.fromJson([
      <String, dynamic>{'insert': t},
    ]);
  }

  /// Serializes [document] for [NoteNode.body].
  static String documentToStorage(Document document) {
    return jsonEncode(document.toDelta().toJson());
  }
}
