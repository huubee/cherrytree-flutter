import 'package:cherrytree_flutter/rich/cherrytree_checkbox_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('toggles [ ] to [x] when tap is on bracket', () {
    final c = QuillController(
      document: Document.fromJson([
        {'insert': '[ ] task\n'},
      ]),
      selection: const TextSelection.collapsed(offset: 0),
    );
    expect(CherrytreeCheckboxToggle.tryToggleAtTapOffset(c, 1), isTrue);
    expect(c.document.toPlainText(), '[x] task\n');
  });

  test('toggles [x] to [ ]', () {
    final c = QuillController(
      document: Document.fromJson([
        {'insert': '[x] done\n'},
      ]),
      selection: const TextSelection.collapsed(offset: 0),
    );
    expect(CherrytreeCheckboxToggle.tryToggleAtTapOffset(c, 1), isTrue);
    expect(c.document.toPlainText(), '[ ] done\n');
  });

  test('does not toggle when tap is past checkbox', () {
    final c = QuillController(
      document: Document.fromJson([
        {'insert': '[ ] label\n'},
      ]),
      selection: const TextSelection.collapsed(offset: 0),
    );
    expect(CherrytreeCheckboxToggle.tryToggleAtTapOffset(c, 8), isFalse);
    expect(c.document.toPlainText(), '[ ] label\n');
  });
}
