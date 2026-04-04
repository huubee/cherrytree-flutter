import '../models/note_document.dart';

/// Result of reading a CherryTree [.ctd] / [.ctb] file into the app model (read-only import).
class CherrytreeReadResult {
  CherrytreeReadResult({
    required this.document,
    this.warnings = const [],
  });

  final NoteDocument document;
  final List<String> warnings;

  bool get hasWarnings => warnings.isNotEmpty;
}
