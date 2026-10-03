import 'package:flutter_quill/flutter_quill.dart';
import 'package:xml/xml.dart';

import '../cherrytree/ct_constants.dart';
import 'note_body_codec.dart';

/// Converts CherryTree `<rich_text>` XML ↔ Quill [Document] for round-trip with desktop.
class CherrytreeQuillBridge {
  CherrytreeQuillBridge._();

  /// CherryTree uses these attribute names on `<rich_text>` (see upstream `ct_const.h`).
  static const _kWeight = 'weight';
  static const _kStyle = 'style';
  static const _kUnderline = 'underline';
  static const _kStrikethrough = 'strikethrough';
  static const _kForeground = 'foreground';
  static const _kBackground = 'background';
  static const _kLink = 'link';

  static const _vHeavy = 'heavy';
  static const _vItalic = 'italic';

  static const _kFamily = 'family';
  static const _kScale = 'scale';
  static const _kJustification = 'justification';

  /// Builds a [Document] from children of a CTD `<node>` (`rich_text`, `codebox`, `table`, `encoded_png`).
  static Document documentFromCtdNode(XmlElement nodeEl) {
    return _documentFromNodeChildElements(
      nodeEl.childElements.where((e) => e.name.local != 'node'),
    );
  }

  /// Builds a [Document] from SQLite [txt] column (`<node>` root with child elements).
  static Document documentFromSqliteRichTxt(String txt) {
    try {
      final doc = XmlDocument.parse(txt);
      final root = doc.rootElement;
      return _documentFromNodeChildElements(
        root.childElements.where((e) => e.name.local != 'node'),
      );
    } on Object {
      return NoteBodyCodec.documentFromStorage(txt);
    }
  }

  static String _directXmlText(XmlElement el) {
    return el.children
        .whereType<XmlText>()
        .map((n) => n.value)
        .join();
  }

  static Document _documentFromNodeChildElements(Iterable<XmlElement> elements) {
    final list = elements.toList();
    if (list.isEmpty) {
      return Document();
    }
    final ops = <Map<String, dynamic>>[];
    for (final el in list) {
      final name = el.name.local;
      switch (name) {
        case 'rich_text':
          final text = _directXmlText(el);
          if (text.isEmpty) continue;
          final attrs = _quillInlineAttrsFromCtElement(el);
          if (attrs.isEmpty) {
            ops.add(<String, dynamic>{'insert': text});
          } else {
            ops.add(<String, dynamic>{'insert': text, 'attributes': attrs});
          }
          break;
        case 'codebox':
          final code = _directXmlText(el);
          final syntax = el.getAttribute('syntax_highlighting') ?? '';
          final lines = code.split('\n');
          for (var i = 0; i < lines.length; i++) {
            if (lines[i].isNotEmpty) {
              ops.add({'insert': lines[i]});
            }
            final blockAttrs = <String, dynamic>{'code-block': true};
            if (syntax.isNotEmpty) {
              blockAttrs['code-block'] = syntax;
            }
            ops.add({
              'insert': '\n',
              'attributes': blockAttrs,
            });
          }
          break;
        case 'table':
          final rows = el.childElements.where((e) => e.name.local == 'row').toList();
          if (rows.isNotEmpty) {
            final tableBuf = StringBuffer('\n');
            for (var r = 0; r < rows.length; r++) {
              final cells = rows[r].childElements.where((e) => e.name.local == 'cell').toList();
              final rowStr = cells.map((c) => _directXmlText(c).replaceAll('|', '\\|').trim()).join(' | ');
              tableBuf.writeln('| $rowStr |');
              if (r == 0) {
                final sep = cells.map((_) => '---').join(' | ');
                tableBuf.writeln('| $sep |');
              }
            }
            tableBuf.writeln();
            ops.add({'insert': tableBuf.toString()});
          }
          break;
        case 'encoded_png':
          final b64 = _directXmlText(el).trim();
          if (b64.isNotEmpty) {
            ops.add({
              'insert': {
                'image': 'data:image/png;base64,$b64',
              },
            });
            ops.add({'insert': '\n'});
          }
          break;
      }
    }
    if (ops.isEmpty) {
      return Document();
    }
    final last = ops.last;
    final lastInsert = last['insert'];
    if (lastInsert is String && !lastInsert.endsWith('\n')) {
      last['insert'] = '$lastInsert\n';
    } else if (lastInsert is! String) {
      ops.add({'insert': '\n'});
    }
    return Document.fromJson(ops);
  }

  static Map<String, dynamic> _quillInlineAttrsFromCtElement(XmlElement el) {
    final attrs = <String, dynamic>{};
    for (final a in el.attributes) {
      final name = a.name.local;
      final value = a.value;
      switch (name) {
        case _kWeight:
          if (value == _vHeavy) attrs['bold'] = true;
          break;
        case _kStyle:
          if (value == _vItalic) attrs['italic'] = true;
          break;
        case _kUnderline:
          if (value.isNotEmpty && value != 'false') attrs['underline'] = true;
          break;
        case _kStrikethrough:
          if (value.isNotEmpty && value != 'false') attrs['strike'] = true;
          break;
        case _kForeground:
          if (value.isNotEmpty) attrs['color'] = value;
          break;
        case _kBackground:
          if (value.isNotEmpty) attrs['background'] = value;
          break;
        case _kLink:
          if (value.isNotEmpty) attrs['link'] = value;
          break;
        case _kFamily:
          if (value == 'monospace') attrs['code'] = true;
          break;
        case _kScale:
          if (value == 'h1') attrs['header'] = 1;
          if (value == 'h2') attrs['header'] = 2;
          if (value == 'h3') attrs['header'] = 3;
          if (value == 'sub') attrs['script'] = 'sub';
          if (value == 'sup') attrs['script'] = 'super';
          break;
        case _kJustification:
          if (value == 'center') attrs['align'] = 'center';
          if (value == 'right') attrs['align'] = 'right';
          if (value == 'fill') attrs['align'] = 'justify';
          break;
        default:
          break;
      }
    }
    return attrs;
  }

  /// Appends `<rich_text>` and `<encoded_png>` children to [b] from [document] (CTD / CTB body payload).
  static void writeRichTextChildren(XmlBuilder b, Document document) {
    final delta = document.toDelta();
    for (final op in delta.toList()) {
      if (!op.isInsert) continue;
      final data = op.data;
      if (data is Map && data.containsKey('image')) {
        final imgUrl = data['image'] as String? ?? '';
        if (imgUrl.startsWith('data:image/png;base64,')) {
          final b64 = imgUrl.substring('data:image/png;base64,'.length);
          b.element(
            'encoded_png',
            attributes: {'char_offset': '0', 'justification': 'left'},
            nest: () {
              b.text(b64);
            },
          );
        }
        continue;
      }
      if (data is! String) continue;
      if (data.isEmpty) continue;
      final ctAttrs = _ctAttrsFromQuill(op.attributes);
      b.element(
        'rich_text',
        attributes: ctAttrs,
        nest: () {
          b.text(data);
        },
      );
    }
  }

  /// Full SQLite [txt] column for a rich node (`syntax` = [kCherrytreeRichTextSyntaxId]).
  static String sqliteTxtFromDocument(Document document) {
    final b = XmlBuilder();
    b.element(
      'node',
      nest: () {
        writeRichTextChildren(b, document);
      },
    );
    return b.buildDocument().toXmlString();
  }

  static Map<String, String> _ctAttrsFromQuill(Map<String, dynamic>? attrs) {
    if (attrs == null || attrs.isEmpty) return {};
    final m = <String, String>{};
    if (attrs['bold'] == true) m[_kWeight] = _vHeavy;
    if (attrs['italic'] == true) m[_kStyle] = _vItalic;
    if (attrs['underline'] == true) m[_kUnderline] = 'true';
    if (attrs['strike'] == true) m[_kStrikethrough] = 'true';
    if (attrs['code'] == true) m[_kFamily] = 'monospace';
    final header = attrs['header'];
    if (header == 1) m[_kScale] = 'h1';
    if (header == 2) m[_kScale] = 'h2';
    if (header == 3) m[_kScale] = 'h3';
    if (attrs['script'] == 'sub') m[_kScale] = 'sub';
    if (attrs['script'] == 'super') m[_kScale] = 'sup';
    final align = attrs['align'];
    if (align == 'center') m[_kJustification] = 'center';
    if (align == 'right') m[_kJustification] = 'right';
    if (align == 'justify') m[_kJustification] = 'fill';
    final fg = _ctRgb24FromQuillColor(attrs['color']?.toString());
    if (fg != null) m[_kForeground] = fg;
    final bg = _ctRgb24FromQuillColor(attrs['background']?.toString());
    if (bg != null) m[_kBackground] = bg;
    final link = attrs['link'];
    if (link != null && '$link'.isNotEmpty) m[_kLink] = '$link';
    return m;
  }

  /// Flutter Quill’s toolbar uses [`colorToHex`] → `#AARRGGBB` (see flutter_quill
  /// `color_button.dart`). CherryTree and GTK [foreground] / [background] expect
  /// `#RRGGBB` (24-bit RGB), same as desktop CherryTree files.
  static String? _ctRgb24FromQuillColor(String? raw) {
    if (raw == null) return null;
    var s = raw.trim();
    if (s.isEmpty) return null;
    if (s.startsWith('#')) s = s.substring(1);
    if (s.length == 8) {
      // AARRGGBB → RRGGBB
      return '#${s.substring(2, 8)}'.toLowerCase();
    }
    if (s.length == 6) {
      return '#$s'.toLowerCase();
    }
    if (s.length == 3) {
      return '#${s[0]}${s[0]}${s[1]}${s[1]}${s[2]}${s[2]}'.toLowerCase();
    }
    return raw;
  }
}
