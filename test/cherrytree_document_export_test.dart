import 'package:cherrytree_flutter/cherrytree/cherrytree_document_export.dart';
import 'package:cherrytree_flutter/models/note_document.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ctdBytes produces XML with cherrytree root', () {
    final doc = NoteDocument(
      nodes: [
        NoteNode(
          id: 'a',
          parentId: null,
          title: 'Root',
          body: '',
          sortIndex: 0,
        ),
      ],
    );
    final bytes = CherrytreeDocumentExport.ctdBytes(doc);
    final s = String.fromCharCodes(bytes);
    expect(s, contains('<cherrytree'));
    expect(s, contains('name="Root"'));
  });
}
