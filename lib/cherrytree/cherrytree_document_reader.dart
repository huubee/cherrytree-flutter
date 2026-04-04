import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'cherrytree_read_result.dart';
import 'ctb_document_reader.dart';
import 'ctd_document_reader.dart';

/// Read-only import: unencrypted [.ctd] (XML) or [.ctb] (SQLite). Encrypted [.ctz] / [.ctx] are rejected.
class CherrytreeDocumentReader {
  CherrytreeDocumentReader._();

  /// Import from a [FilePicker] result (uses [PlatformFile.path] when present, otherwise bytes + temp file for [.ctb]).
  static Future<CherrytreeReadResult> readFromPickedFile(PlatformFile file) async {
    final name = file.name.toLowerCase();
    if (name.endsWith('.ctz') || name.endsWith('.ctx')) {
      throw CherrytreeEncryptedImportException();
    }
    if (file.path != null) {
      return readFile(file.path!);
    }
    final bytes = file.bytes;
    if (bytes == null) {
      throw StateError('No path or bytes for picked file.');
    }
    if (name.endsWith('.ctd')) {
      return CtdDocumentReader.readBytes(bytes);
    }
    if (name.endsWith('.ctb')) {
      final dir = await getTemporaryDirectory();
      final temp = File(
        p.join(dir.path, 'ct_import_${DateTime.now().millisecondsSinceEpoch}.ctb'),
      );
      await temp.writeAsBytes(bytes, flush: true);
      try {
        return await CtbDocumentReader.readPath(temp.path);
      } finally {
        try {
          await temp.delete();
        } on Object {
          // best-effort cleanup
        }
      }
    }
    throw FormatException('Unsupported file type. Use a CherryTree .ctd or .ctb document.');
  }

  static Future<CherrytreeReadResult> readFile(String path) async {
    final lower = path.toLowerCase();
    if (lower.endsWith('.ctz') || lower.endsWith('.ctx')) {
      throw CherrytreeEncryptedImportException();
    }
    if (lower.endsWith('.ctd')) {
      final bytes = await File(path).readAsBytes();
      return CtdDocumentReader.readBytes(bytes);
    }
    if (lower.endsWith('.ctb')) {
      return CtbDocumentReader.readPath(path);
    }
    throw FormatException('Unsupported file type. Use a CherryTree .ctd or .ctb document.');
  }
}

/// Thrown when the user picks an encrypted CherryTree archive (.ctz / .ctx).
class CherrytreeEncryptedImportException implements Exception {
  CherrytreeEncryptedImportException();
}
