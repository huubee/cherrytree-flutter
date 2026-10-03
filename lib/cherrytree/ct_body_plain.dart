import 'package:xml/xml.dart';

import '../rich/cherrytree_quill_bridge.dart';
import '../rich/note_body_codec.dart';
import 'ct_constants.dart';

/// Plain-text extraction for Spike B: titles and body text only (no images/tables/code boxes).
class CtBodyPlain {
  CtBodyPlain._();

  /// When each `<rich_text>` slot becomes one line, a checkbox and its label can end up
  /// on adjacent lines (`[ ]` then `smbtree`). Merge those into a single line like CherryTree.
  static String normalizeSeparatedCheckboxLines(String body) {
    final raw = body.split(RegExp(r'\r?\n'));
    final out = <String>[];
    for (var i = 0; i < raw.length; i++) {
      final line = raw[i];
      if (i + 1 < raw.length &&
          _isStandaloneCheckboxOnly(line) &&
          _isMergeableCheckboxContinuation(raw[i + 1])) {
        out.add('${line.trimRight()} ${raw[i + 1].trimLeft()}');
        i++;
      } else {
        out.add(line);
      }
    }
    return out.join('\n');
  }

  static bool _isStandaloneCheckboxOnly(String line) {
    final t = line.trim();
    if (t.isEmpty) return false;
    return RegExp(r'^(?:[-*+]\s+)?\[[ xX]\]\s*$').hasMatch(t);
  }

  /// Next line after a standalone checkbox line: real content, not another empty checkbox.
  static bool _isMergeableCheckboxContinuation(String line) {
    final t = line.trimLeft();
    if (t.isEmpty) return false;
    if (_isStandaloneCheckboxOnly(line)) return false;
    if (RegExp(r'^#+\s').hasMatch(t)) return false;
    return true;
  }

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
          final code = richTextDirectText(child).trim();
          if (code.isNotEmpty) {
            out.write('\n$code\n');
          }
          break;
        case 'table':
          final rows = child.childElements.where((e) => e.name.local == 'row');
          for (final row in rows) {
            final cells = row.childElements.where((e) => e.name.local == 'cell');
            final cellTexts = cells.map(richTextDirectText).join(' | ');
            if (cellTexts.isNotEmpty) {
              out.write('| $cellTexts |\n');
            }
          }
          break;
        case 'encoded_png':
          break;
        default:
          warnings.add('Unsupported slot: ${child.name.local}');
          unsupportedSlot = true;
      }
    }
    return (
      normalizeSeparatedCheckboxLines(out.toString().trimRight()),
      unsupportedSlot,
    );
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
        } else if (child.name.local == 'codebox') {
          buffer.writeln(richTextDirectText(child));
        } else if (child.name.local == 'table') {
          final rows = child.childElements.where((e) => e.name.local == 'row');
          for (final row in rows) {
            final cells = row.childElements.where((e) => e.name.local == 'cell');
            buffer.writeln(cells.map(richTextDirectText).join(' | '));
          }
        }
      }
      return normalizeSeparatedCheckboxLines(buffer.toString().trimRight());
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
      final doc = CherrytreeQuillBridge.documentFromSqliteRichTxt(t);
      return NoteBodyCodec.documentToStorage(doc);
    }
    return normalizeSeparatedCheckboxLines(t);
  }
}
