import 'package:cherrytree_flutter/cherrytree/ctd_document_reader.dart';
import 'package:flutter_test/flutter_test.dart';

import 'rich_test_utils.dart';

void main() {
  group('CtdDocumentReader', () {
    test('reads tree and plain rich_text', () {
      const xml = '''
<?xml version="1.0" encoding="UTF-8"?>
<cherrytree>
  <node unique_id="1" master_id="0" name="Root" prog_lang="plain-text" tags="" readonly="0" nosearch_me="0" nosearch_ch="0" custom_icon_id="0" is_bold="0" foreground="" ts_creation="0" ts_lastsave="0">
    <rich_text>Hello</rich_text>
    <node unique_id="2" master_id="0" name="Child" prog_lang="plain-text" tags="" readonly="0" nosearch_me="0" nosearch_ch="0" custom_icon_id="0" is_bold="0" foreground="" ts_creation="0" ts_lastsave="0">
      <rich_text>Nested</rich_text>
    </node>
  </node>
</cherrytree>
''';
      final r = CtdDocumentReader.readString(xml);
      expect(r.document.nodes.length, 2);
      expect(r.document.find('ct-1')?.title, 'Root');
      expect(plainBody(r.document.find('ct-1')!.body), 'Hello');
      expect(r.document.find('ct-2')?.parentId, 'ct-1');
      expect(plainBody(r.document.find('ct-2')!.body), 'Nested');
    });
  });
}
