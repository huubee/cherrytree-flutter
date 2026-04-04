import 'note_document.dart';

/// One open document in the multi-tab shell (JSON backup + optional CherryTree path).
class DocumentTab {
  DocumentTab({
    required this.id,
    required this.document,
    this.selectedNodeId,
    this.cherrytreeMode,
    this.cherrytreePath,
    this.tabLabel,
  });

  final String id;
  final NoteDocument document;
  String? selectedNodeId;
  String? cherrytreeMode;
  String? cherrytreePath;
  /// Optional label shown in the tab strip; when null/empty, the first root note title is used.
  String? tabLabel;
}
