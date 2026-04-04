import 'package:cherrytree_flutter/rich/cherrytree_quill_bridge.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';

void main() {
  test('two consecutive rich_text (checkbox + link) stays one line in plain text', () {
    final xml = '''
<node unique_id="1" master_id="0" name="Root" prog_lang="custom-colors">
  <rich_text>[ ] </rich_text>
  <rich_text link="webs https://example.com" foreground="#00ff00">Nikito</rich_text>
</node>
''';
    final el = XmlDocument.parse(xml).rootElement;
    final doc = CherrytreeQuillBridge.documentFromCtdNode(el);
    expect(doc.toPlainText().trim(), '[ ] Nikito');

    var sawLinkOnNikito = false;
    for (final op in doc.toDelta().toList()) {
      if (!op.isInsert || op.data is! String) continue;
      final s = op.data as String;
      if (s.contains('Nikito')) {
        expect(op.attributes?['link'], 'webs https://example.com');
        sawLinkOnNikito = true;
      }
    }
    expect(sawLinkOnNikito, isTrue);
  });
}
