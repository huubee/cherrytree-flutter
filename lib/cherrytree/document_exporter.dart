import 'dart:convert';

import '../models/note_document.dart';
import '../rich/note_body_codec.dart';

/// Exports a [NoteDocument] or subset of nodes to Markdown, HTML, and Plain Text.
class DocumentExporter {
  DocumentExporter._();

  /// Converts nodes to GitHub Flavored Markdown.
  static String exportToMarkdown(
    NoteDocument doc, {
    String? nodeId,
    bool recursive = true,
  }) {
    final buffer = StringBuffer();
    final nodes = _collectNodes(doc, nodeId: nodeId, recursive: recursive);

    for (var i = 0; i < nodes.length; i++) {
      final item = nodes[i];
      final node = item.node;
      final depth = item.depth;

      // Heading level: 1 to 6
      final hashes = '#' * depth.clamp(1, 6);
      buffer.writeln('$hashes ${node.title.trim().isEmpty ? 'Untitled' : node.title.trim()}\n');

      if (node.tags.trim().isNotEmpty) {
        buffer.writeln('> **Tags**: ${node.tags.trim()}\n');
      }

      final bodyMarkdown = _bodyToMarkdown(node.body);
      if (bodyMarkdown.isNotEmpty) {
        buffer.writeln(bodyMarkdown);
        buffer.writeln();
      }

      if (i < nodes.length - 1) {
        buffer.writeln('---\n');
      }
    }

    return buffer.toString().trimRight();
  }

  /// Converts nodes to standalone HTML5 with embedded responsive styling.
  static String exportToHtml(
    NoteDocument doc, {
    String? nodeId,
    bool recursive = true,
    String title = 'CherryTree Notes',
  }) {
    final nodes = _collectNodes(doc, nodeId: nodeId, recursive: recursive);
    final buffer = StringBuffer();

    buffer.writeln('<!DOCTYPE html>');
    buffer.writeln('<html lang="en">');
    buffer.writeln('<head>');
    buffer.writeln('  <meta charset="UTF-8">');
    buffer.writeln('  <meta name="viewport" content="width=device-width, initial-scale=1.0">');
    buffer.writeln('  <title>${_htmlEscape(title)}</title>');
    buffer.writeln('  <style>');
    buffer.writeln('''
    :root {
      --bg: #ffffff;
      --text: #24292f;
      --text-muted: #57606a;
      --border: #d0d7de;
      --card-bg: #f6f8fa;
      --accent: #0969da;
      --code-bg: #f6f8fa;
      --code-border: #d0d7de;
      --table-stripe: #f6f8fa;
    }
    @media (prefers-color-scheme: dark) {
      :root {
        --bg: #0d1117;
        --text: #c9d1d9;
        --text-muted: #8b949e;
        --border: #30363d;
        --card-bg: #161b22;
        --accent: #58a6ff;
        --code-bg: #161b22;
        --code-border: #30363d;
        --table-stripe: #161b22;
      }
    }
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
      line-height: 1.6;
      color: var(--text);
      background: var(--bg);
      max-width: 900px;
      margin: 0 auto;
      padding: 2rem 1.5rem;
    }
    h1, h2, h3, h4, h5, h6 {
      color: var(--text);
      margin-top: 1.5rem;
      margin-bottom: 0.5rem;
      font-weight: 600;
    }
    h1 { font-size: 2rem; border-bottom: 1px solid var(--border); padding-bottom: 0.3rem; }
    h2 { font-size: 1.5rem; border-bottom: 1px solid var(--border); padding-bottom: 0.25rem; }
    h3 { font-size: 1.25rem; }
    p { margin: 0.6rem 0; }
    a { color: var(--accent); text-decoration: none; }
    a:hover { text-decoration: underline; }
    blockquote {
      border-left: 4px solid var(--accent);
      margin: 1rem 0;
      padding: 0.5rem 1rem;
      color: var(--text-muted);
      background: var(--card-bg);
      border-radius: 0 4px 4px 0;
    }
    pre {
      background: var(--code-bg);
      border: 1px solid var(--code-border);
      border-radius: 6px;
      padding: 1rem;
      overflow-x: auto;
      font-family: ui-monospace, SFMono-Regular, "SF Mono", Menlo, Consolas, monospace;
      font-size: 0.9rem;
    }
    code {
      font-family: ui-monospace, SFMono-Regular, "SF Mono", Menlo, Consolas, monospace;
      background: var(--code-bg);
      padding: 0.2em 0.4em;
      border-radius: 3px;
      font-size: 85%;
    }
    pre code { background: transparent; padding: 0; }
    table {
      border-collapse: collapse;
      width: 100%;
      margin: 1rem 0;
    }
    th, td {
      border: 1px solid var(--border);
      padding: 0.5rem 0.8rem;
      text-align: left;
    }
    th {
      background: var(--card-bg);
      font-weight: 600;
    }
    tr:nth-child(even) { background: var(--table-stripe); }
    hr {
      border: none;
      border-top: 1px solid var(--border);
      margin: 2rem 0;
    }
    .node-tags {
      display: inline-block;
      font-size: 0.85rem;
      color: var(--text-muted);
      background: var(--card-bg);
      border: 1px solid var(--border);
      border-radius: 12px;
      padding: 0.2rem 0.6rem;
      margin-bottom: 1rem;
    }
    .toc {
      background: var(--card-bg);
      border: 1px solid var(--border);
      border-radius: 8px;
      padding: 1.2rem;
      margin-bottom: 2rem;
    }
    .toc ul { list-style: none; padding-left: 1.2rem; margin: 0.4rem 0; }
    .toc > ul { padding-left: 0; }
    img { max-width: 100%; height: auto; border-radius: 6px; }
''');
    buffer.writeln('  </style>');
    buffer.writeln('</head>');
    buffer.writeln('<body>');

    // Table of contents for multiple nodes
    if (nodes.length > 1) {
      buffer.writeln('  <nav class="toc">');
      buffer.writeln('    <strong>Table of Contents</strong>');
      buffer.writeln('    <ul>');
      for (final item in nodes) {
        final node = item.node;
        final title = node.title.trim().isEmpty ? 'Untitled' : node.title.trim();
        final indent = '  ' * item.depth;
        buffer.writeln('$indent    <li><a href="#node-${node.id}">$title</a></li>');
      }
      buffer.writeln('    </ul>');
      buffer.writeln('  </nav>');
    }

    for (final item in nodes) {
      final node = item.node;
      final depth = item.depth.clamp(1, 6);
      final title = node.title.trim().isEmpty ? 'Untitled' : node.title.trim();

      buffer.writeln('  <article id="node-${node.id}">');
      buffer.writeln('    <h$depth>$title</h$depth>');

      if (node.tags.trim().isNotEmpty) {
        buffer.writeln('    <div class="node-tags">Tags: ${_htmlEscape(node.tags.trim())}</div>');
      }

      final bodyHtml = _bodyToHtml(node.body);
      buffer.writeln(bodyHtml);
      buffer.writeln('  </article>');
      buffer.writeln('  <hr>');
    }

    buffer.writeln('</body>');
    buffer.writeln('</html>');

    return buffer.toString();
  }

  /// Converts nodes to an indented plain text outline.
  static String exportToPlainText(
    NoteDocument doc, {
    String? nodeId,
    bool recursive = true,
  }) {
    final buffer = StringBuffer();
    final nodes = _collectNodes(doc, nodeId: nodeId, recursive: recursive);

    for (final item in nodes) {
      final node = item.node;
      final title = node.title.trim().isEmpty ? 'Untitled' : node.title.trim();
      final line = '=' * title.length.clamp(20, 60);

      buffer.writeln(line);
      buffer.writeln(title);
      buffer.writeln(line);

      if (node.tags.trim().isNotEmpty) {
        buffer.writeln('[Tags: ${node.tags.trim()}]');
      }

      final plain = _bodyToPlainText(node.body);
      if (plain.isNotEmpty) {
        buffer.writeln(plain);
      }
      buffer.writeln();
    }

    return buffer.toString().trimRight();
  }

  static List<_NodeWithDepth> _collectNodes(
    NoteDocument doc, {
    String? nodeId,
    bool recursive = true,
  }) {
    final results = <_NodeWithDepth>[];

    if (nodeId == null) {
      // Entire tree starting from roots
      for (final root in doc.childrenOf(null)) {
        _traverse(doc, root, 1, recursive, results);
      }
    } else {
      final start = doc.find(nodeId);
      if (start != null) {
        _traverse(doc, start, 1, recursive, results);
      }
    }

    return results;
  }

  static void _traverse(
    NoteDocument doc,
    NoteNode node,
    int depth,
    bool recursive,
    List<_NodeWithDepth> results,
  ) {
    results.add(_NodeWithDepth(node, depth));
    if (recursive) {
      for (final child in doc.childrenOf(node.id)) {
        _traverse(doc, child, depth + 1, recursive, results);
      }
    }
  }

  static String _bodyToPlainText(String body) {
    if (NoteBodyCodec.looksLikeQuillDeltaJson(body)) {
      final doc = NoteBodyCodec.documentFromStorage(body);
      return doc.toPlainText().trim();
    }
    return body.trim();
  }

  static String _bodyToMarkdown(String body) {
    if (!NoteBodyCodec.looksLikeQuillDeltaJson(body)) {
      return body.trim();
    }
    final doc = NoteBodyCodec.documentFromStorage(body);
    final delta = doc.toDelta();
    final out = StringBuffer();

    for (final op in delta.toList()) {
      if (!op.isInsert) continue;
      final data = op.data;

      if (data is Map && data.containsKey('image')) {
        final imgUrl = data['image'] as String? ?? '';
        out.write('![Image]($imgUrl)\n');
        continue;
      }

      if (data is! String) continue;

      var text = data;
      final attrs = op.attributes;

      if (attrs != null && attrs.isNotEmpty) {
        if (attrs['bold'] == true) text = '**$text**';
        if (attrs['italic'] == true) text = '*$text*';
        if (attrs['strike'] == true) text = '~~$text~~';
        if (attrs['code'] == true) text = '`$text`';
        final link = attrs['link'];
        if (link != null && '$link'.isNotEmpty) {
          text = '[$text]($link)';
        }
      }

      out.write(text);
    }

    return out.toString().trim();
  }

  static String _bodyToHtml(String body) {
    if (!NoteBodyCodec.looksLikeQuillDeltaJson(body)) {
      return '<p>${_htmlEscape(body.trim()).replaceAll('\n', '<br>')}</p>';
    }

    final doc = NoteBodyCodec.documentFromStorage(body);
    final delta = doc.toDelta();
    final out = StringBuffer();
    var inCodeBlock = false;
    var currentParagraph = StringBuffer();

    void flushParagraph() {
      if (currentParagraph.isNotEmpty) {
        out.writeln('    <p>${currentParagraph.toString()}</p>');
        currentParagraph = StringBuffer();
      }
    }

    for (final op in delta.toList()) {
      if (!op.isInsert) continue;
      final data = op.data;

      if (data is Map && data.containsKey('image')) {
        flushParagraph();
        final img = data['image'] as String? ?? '';
        out.writeln('    <p><img src="$img" alt="Embedded Image"></p>');
        continue;
      }

      if (data is! String) continue;

      final attrs = op.attributes;
      final isCodeBlock = attrs != null && attrs.containsKey('code-block');

      if (isCodeBlock) {
        if (!inCodeBlock) {
          flushParagraph();
          inCodeBlock = true;
          out.writeln('    <pre><code>');
        }
        out.write(_htmlEscape(data));
        continue;
      } else if (inCodeBlock) {
        inCodeBlock = false;
        out.writeln('</code></pre>');
      }

      var text = _htmlEscape(data);

      if (attrs != null && attrs.isNotEmpty) {
        if (attrs['bold'] == true) text = '<strong>$text</strong>';
        if (attrs['italic'] == true) text = '<em>$text</em>';
        if (attrs['underline'] == true) text = '<u>$text</u>';
        if (attrs['strike'] == true) text = '<s>$text</s>';
        if (attrs['code'] == true) text = '<code>$text</code>';
        if (attrs['script'] == 'sub') text = '<sub>$text</sub>';
        if (attrs['script'] == 'super') text = '<sup>$text</sup>';
        final link = attrs['link'];
        if (link != null && '$link'.isNotEmpty) {
          text = '<a href="${_htmlEscape(link.toString())}">$text</a>';
        }
      }

      if (text.contains('\n')) {
        final parts = text.split('\n');
        for (var i = 0; i < parts.length; i++) {
          currentParagraph.write(parts[i]);
          if (i < parts.length - 1) {
            flushParagraph();
          }
        }
      } else {
        currentParagraph.write(text);
      }
    }

    if (inCodeBlock) {
      out.writeln('</code></pre>');
    }
    flushParagraph();

    return out.toString();
  }

  static String _htmlEscape(String input) {
    return const HtmlEscape().convert(input);
  }
}

class _NodeWithDepth {
  final NoteNode node;
  final int depth;

  _NodeWithDepth(this.node, this.depth);
}
