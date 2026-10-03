import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../cherrytree/cherrytree_document_export.dart';
import '../cherrytree/document_exporter.dart';
import '../l10n/app_localizations.dart';
import '../models/note_document.dart';

enum ExportScope {
  entireTree,
  selectedWithSubnodes,
  selectedOnly,
}

enum ExportFormat {
  markdown,
  html,
  plainText,
  ctdXml,
  ctbSqlite,
}

/// Comprehensive export modal allowing user to choose scope (entire tree, subnodes, node)
/// and format (Markdown, HTML, Plain Text, .ctd, .ctb) with Save to File, Share, and Copy.
class ExportDialog extends StatefulWidget {
  const ExportDialog({
    super.key,
    required this.doc,
    this.selectedNodeId,
  });

  final NoteDocument doc;
  final String? selectedNodeId;

  static Future<void> show(
    BuildContext context, {
    required NoteDocument doc,
    String? selectedNodeId,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => ExportDialog(
        doc: doc,
        selectedNodeId: selectedNodeId,
      ),
    );
  }

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  late ExportScope _scope;
  ExportFormat _format = ExportFormat.markdown;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _scope = widget.selectedNodeId != null
        ? ExportScope.selectedWithSubnodes
        : ExportScope.entireTree;
  }

  String _formatExtension(ExportFormat format) {
    switch (format) {
      case ExportFormat.markdown:
        return 'md';
      case ExportFormat.html:
        return 'html';
      case ExportFormat.plainText:
        return 'txt';
      case ExportFormat.ctdXml:
        return 'ctd';
      case ExportFormat.ctbSqlite:
        return 'ctb';
    }
  }

  String _formatMimeType(ExportFormat format) {
    switch (format) {
      case ExportFormat.markdown:
        return 'text/markdown';
      case ExportFormat.html:
        return 'text/html';
      case ExportFormat.plainText:
        return 'text/plain';
      case ExportFormat.ctdXml:
        return 'application/xml';
      case ExportFormat.ctbSqlite:
        return 'application/vnd.sqlite3';
    }
  }

  String _generateTextOutput() {
    final nodeId = _scope == ExportScope.entireTree ? null : widget.selectedNodeId;
    final recursive = _scope != ExportScope.selectedOnly;

    switch (_format) {
      case ExportFormat.markdown:
        return DocumentExporter.exportToMarkdown(
          widget.doc,
          nodeId: nodeId,
          recursive: recursive,
        );
      case ExportFormat.html:
        return DocumentExporter.exportToHtml(
          widget.doc,
          nodeId: nodeId,
          recursive: recursive,
          title: 'CherryTree Export',
        );
      case ExportFormat.plainText:
        return DocumentExporter.exportToPlainText(
          widget.doc,
          nodeId: nodeId,
          recursive: recursive,
        );
      case ExportFormat.ctdXml:
      case ExportFormat.ctbSqlite:
        return '';
    }
  }

  Future<Uint8List> _generateBytesOutput() async {
    final nodeId = _scope == ExportScope.entireTree ? null : widget.selectedNodeId;
    final recursive = _scope != ExportScope.selectedOnly;

    switch (_format) {
      case ExportFormat.markdown:
        return CherrytreeDocumentExport.markdownBytes(
          widget.doc,
          nodeId: nodeId,
          recursive: recursive,
        );
      case ExportFormat.html:
        return CherrytreeDocumentExport.htmlBytes(
          widget.doc,
          nodeId: nodeId,
          recursive: recursive,
        );
      case ExportFormat.plainText:
        return CherrytreeDocumentExport.plainTextBytes(
          widget.doc,
          nodeId: nodeId,
          recursive: recursive,
        );
      case ExportFormat.ctdXml:
        return CherrytreeDocumentExport.ctdBytes(widget.doc);
      case ExportFormat.ctbSqlite:
        return await CherrytreeDocumentExport.ctbBytes(widget.doc);
    }
  }

  Future<void> _onCopyToClipboard(AppLocalizations l10n) async {
    final text = _generateTextOutput();
    if (text.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.exportCopiedToClipboard)),
    );
  }

  Future<void> _onSaveToFile(AppLocalizations l10n) async {
    setState(() => _isProcessing = true);
    try {
      final ext = _formatExtension(_format);
      final fileName = 'cherrytree_export.$ext';
      final bytes = await _generateBytesOutput();

      final path = await FilePicker.platform.saveFile(
        dialogTitle: l10n.exportDialogTitle,
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: [ext],
        bytes: bytes,
      );

      if (!mounted) return;
      Navigator.of(context).pop();
      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.exportCherryTreeSuccess)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.exportCherryTreeFailed('$e'))),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _onShare(AppLocalizations l10n) async {
    setState(() => _isProcessing = true);
    try {
      final ext = _formatExtension(_format);
      final fileName = 'cherrytree_export.$ext';
      final bytes = await _generateBytesOutput();

      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              bytes,
              name: fileName,
              mimeType: _formatMimeType(_format),
            ),
          ],
          subject: l10n.exportDialogTitle,
          fileNameOverrides: [fileName],
        ),
      );

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.exportCherryTreeFailed('$e'))),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final hasSelection = widget.selectedNodeId != null;

    final isTextExport = _format == ExportFormat.markdown ||
        _format == ExportFormat.html ||
        _format == ExportFormat.plainText;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.ios_share_outlined, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    l10n.exportDialogTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 16),

              // Scope
              Text('Scope', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              SegmentedButton<ExportScope>(
                segments: [
                  ButtonSegment(
                    value: ExportScope.entireTree,
                    label: Text(l10n.exportScopeEntireTree),
                    icon: const Icon(Icons.account_tree_outlined, size: 16),
                  ),
                  if (hasSelection) ...[
                    ButtonSegment(
                      value: ExportScope.selectedWithSubnodes,
                      label: Text(l10n.exportScopeSelectedWithSubnodes),
                    ),
                    ButtonSegment(
                      value: ExportScope.selectedOnly,
                      label: Text(l10n.exportScopeSelectedOnly),
                    ),
                  ],
                ],
                selected: {_scope},
                onSelectionChanged: (set) => setState(() => _scope = set.first),
              ),
              const SizedBox(height: 16),

              // Format
              Text(l10n.exportFormatLabel, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Markdown (.md)'),
                    selected: _format == ExportFormat.markdown,
                    onSelected: (_) => setState(() => _format = ExportFormat.markdown),
                  ),
                  ChoiceChip(
                    label: const Text('HTML (.html)'),
                    selected: _format == ExportFormat.html,
                    onSelected: (_) => setState(() => _format = ExportFormat.html),
                  ),
                  ChoiceChip(
                    label: const Text('Plain Text (.txt)'),
                    selected: _format == ExportFormat.plainText,
                    onSelected: (_) => setState(() => _format = ExportFormat.plainText),
                  ),
                  ChoiceChip(
                    label: const Text('CherryTree XML (.ctd)'),
                    selected: _format == ExportFormat.ctdXml,
                    onSelected: (_) => setState(() => _format = ExportFormat.ctdXml),
                  ),
                  ChoiceChip(
                    label: const Text('CherryTree SQLite (.ctb)'),
                    selected: _format == ExportFormat.ctbSqlite,
                    onSelected: (_) => setState(() => _format = ExportFormat.ctbSqlite),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (_isProcessing)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                // Action Buttons
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (isTextExport)
                      TextButton.icon(
                        icon: const Icon(Icons.copy_outlined, size: 18),
                        label: Text(l10n.exportCopyToClipboard),
                        onPressed: () => _onCopyToClipboard(l10n),
                      ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.share_outlined, size: 18),
                      label: const Text('Share'),
                      onPressed: () => _onShare(l10n),
                    ),
                    FilledButton.icon(
                      icon: const Icon(Icons.save_alt_outlined, size: 18),
                      label: Text(l10n.exportSaveToFile),
                      onPressed: () => _onSaveToFile(l10n),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
