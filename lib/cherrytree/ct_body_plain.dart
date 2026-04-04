import 'package:xml/xml.dart';

import 'ct_constants.dart';

/// Plain-text extraction for Spike B: titles and body text only (no images/tables/code boxes).
class CtBodyPlain {
  CtBodyPlain._();

  static String richTextDirectText(XmlElement el) {
    return el.children
        .whereType<XmlText>()
        .map((n) => n.value)
        .join();
  }

  /// Body from a `<node>` element in a [.ctd] file (child slots: `rich_text`, `codebox`, …).
  /// Returns plain text and whether non-text slots were skipped (caller may warn once).
  static (String body, bool hadUnsupportedSlots) fromCtdNode(
    XmlElement nodeEl,
    List<String> warnings,
  ) {
    final out = StringBuffer();
    var unsupportedSlot = false;
    for (final child in nodeEl.childElements) {
      switch (child.name.local) {
        case 'node':
          break;
        case 'rich_text':
          out.write(richTextDirectText(child));
          out.write('\n');
          break;
        case 'codebox':
        case 'table':
        case 'encoded_png':
          unsupportedSlot = true;
          break;
        default:
          warnings.add('Unsupported slot: ${child.name.local}');
          unsupportedSlot = true;
      }
    }
    return (out.toString().trimRight(), unsupportedSlot);
  }

  /// [txt] column for rich-text nodes: XML with root `<node>` wrapping `<rich_text>` slots.
  static String fromSqliteRichTxt(String txt) {
    try {
      final doc = XmlDocument.parse(txt);
      final root = doc.rootElement;
      final buffer = StringBuffer();
      for (final child in root.childElements) {
        if (child.name.local == 'rich_text') {
          buffer.writeln(richTextDirectText(child));
        }
      }
      return buffer.toString().trimRight();
    } on Object {
      return txt;
    }
  }

  static String fromSqliteNode({
    required String? txt,
    required String? syntax,
  }) {
    final t = txt ?? '';
    final syn = syntax ?? '';
    if (syn == kCherrytreeRichTextSyntaxId) {
      return fromSqliteRichTxt(t);
    }
    return t;
  }
}
