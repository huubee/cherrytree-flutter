import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../l10n/app_localizations.dart';
import '../models/note_document.dart';
import '../rich/note_body_codec.dart';
import '../theme/app_spacing.dart';

class NodeEditor extends StatefulWidget {
  const NodeEditor({
    super.key,
    required this.node,
    required this.onChanged,
  });

  final NoteNode? node;
  final VoidCallback onChanged;

  @override
  State<NodeEditor> createState() => _NodeEditorState();
}

class _NodeEditorState extends State<NodeEditor> {
  late TextEditingController _title;
  late QuillController _quill;
  late FocusNode _bodyFocus;
  late ScrollController _bodyScroll;

  @override
  void initState() {
    super.initState();
    final n = widget.node;
    _title = TextEditingController(text: n?.title ?? '');
    _bodyFocus = FocusNode();
    _bodyScroll = ScrollController();
    _quill = QuillController(
      document: NoteBodyCodec.documentFromStorage(n?.body ?? ''),
      selection: const TextSelection.collapsed(offset: 0),
    );
    _quill.addListener(_onQuillChanged);
  }

  void _onQuillChanged() {
    final n = widget.node;
    if (n == null) return;
    n.body = NoteBodyCodec.documentToStorage(_quill.document);
    widget.onChanged();
  }

  @override
  void didUpdateWidget(covariant NodeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.node?.id != widget.node?.id) {
      _title.text = widget.node?.title ?? '';
      _quill.document = NoteBodyCodec.documentFromStorage(widget.node?.body ?? '');
    }
  }

  @override
  void dispose() {
    _quill.removeListener(_onQuillChanged);
    _quill.dispose();
    _title.dispose();
    _bodyFocus.dispose();
    _bodyScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final n = widget.node;
    if (n == null) {
      return Center(child: Text(l10n.emptyEditorHint));
    }
    final bottomSafe = MediaQuery.paddingOf(context).bottom;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final bodyFill = isDark
        ? scheme.surfaceContainerHighest.withValues(alpha: 0.45)
        : scheme.surfaceContainerHighest.withValues(alpha: 0.35);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.editorPadding,
        AppSpacing.editorPadding,
        AppSpacing.editorPadding,
        AppSpacing.editorPadding + bottomSafe,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _title,
            decoration: InputDecoration(
              labelText: l10n.fieldTitle,
              border: const OutlineInputBorder(),
            ),
            onChanged: (v) {
              n.title = v;
              widget.onChanged();
            },
          ),
          const SizedBox(height: AppSpacing.editorFieldGap),
          QuillSimpleToolbar(
            controller: _quill,
            config: const QuillSimpleToolbarConfig(
              showFontFamily: false,
              showFontSize: false,
              multiRowsDisplay: false,
              showSearchButton: false,
              showLink: false,
              showCodeBlock: false,
              showQuote: false,
              showIndent: false,
              showListNumbers: false,
              showListBullets: false,
              showListCheck: false,
              showSubscript: false,
              showSuperscript: false,
              showHeaderStyle: false,
              showLineHeightButton: false,
              showInlineCode: false,
              showAlignmentButtons: false,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: Material(
              color: bodyFill,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(color: theme.dividerColor),
              ),
              clipBehavior: Clip.antiAlias,
              child: QuillEditor.basic(
                controller: _quill,
                focusNode: _bodyFocus,
                scrollController: _bodyScroll,
                config: QuillEditorConfig(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  expands: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
