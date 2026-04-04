import 'package:shared_preferences/shared_preferences.dart';

/// When set, the app loads/saves the working copy from this CherryTree file path
/// (in addition to the JSON backup in app documents).
///
/// JSON always remains the Spike A safety net: if prefs are unset or the CT path
/// is unusable, [NoteRepository.load] still has a local document to open.
class DocumentStoragePrefs {
  DocumentStoragePrefs._();

  static const _keyMode = 'document_storage_cherrytree_mode';
  static const _keyPath = 'document_storage_cherrytree_path';

  /// `ctd`, `ctb`, or absent / empty for JSON-only.
  static Future<String?> getCherrytreeMode() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_keyMode);
  }

  static Future<String?> getCherrytreePath() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_keyPath);
  }

  /// Call after a successful import when [path] is non-null (same file we round-trip to).
  static Future<void> setCherrytreeFile({
    required String mode,
    required String path,
  }) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_keyMode, mode);
    await p.setString(_keyPath, path);
  }

  static Future<void> clearCherrytreeFile() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_keyMode);
    await p.remove(_keyPath);
  }
}
