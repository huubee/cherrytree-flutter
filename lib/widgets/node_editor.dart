import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../l10n/app_localizations.dart';
import '../models/note_document.dart';
import '../rich/cherrytree_checkbox_toggle.dart';
import '../rich/note_body_codec.dart';
import '../theme/app_spacing.dart';
import 'special_characters_dialog.dart';

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
      readOnly: n?.isReadOnly ?? false,
    );
    _quill.addListener(_onQuillChanged);
  }

  void _onQuillChanged() {
    final n = widget.node;
    if (n == null || n.isReadOnly) return;
    n.body = NoteBodyCodec.documentToStorage(_quill.document);
    widget.onChanged();
  }

  void _insertText(String text) {
    final sel = _quill.selection;
    final index = sel.baseOffset >= 0 ? sel.baseOffset : _quill.document.length - 1;
    final len = sel.extentOffset > index ? sel.extentOffset - index : 0;
    _quill.replaceText(index, len, text, null);
    _quill.updateSelection(
      TextSelection.collapsed(offset: index + text.length),
      ChangeSource.local,
    );
  }

  void _insertTimestamp() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    final h = now.hour.toString().padLeft(2, '0');
    final min = now.minute.toString().padLeft(2, '0');
    _insertText('$y/$m/$d - $h:$min');
  }

  void _insertHorizontalRule() {
    _insertText('\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n');
  }

  void _openSpecialCharacters() {
    unawaited(
      SpecialCharactersDialog.show(
        context,
        onSelectCharacter: (char) => _insertText(char),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant NodeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.node?.id != widget.node?.id ||
        oldWidget.node?.isReadOnly != widget.node?.isReadOnly) {
      _title.text = widget.node?.title ?? '';
      _quill.document =
          NoteBodyCodec.documentFromStorage(widget.node?.body ?? '');
      _quill.readOnly = widget.node?.isReadOnly ?? false;
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

    final isReadOnly = n.isReadOnly;

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
            readOnly: isReadOnly,
            decoration: InputDecoration(
              labelText: l10n.fieldTitle,
              border: const OutlineInputBorder(),
              prefixIcon: isReadOnly
                  ? const Icon(Icons.lock_outline, size: 20)
                  : null,
            ),
            onChanged: isReadOnly
                ? null
                : (v) {
                    n.title = v;
                    widget.onChanged();
                  },
          ),
          if (!isReadOnly) ...[
            const SizedBox(height: AppSpacing.editorFieldGap),
            QuillSimpleToolbar(
              controller: _quill,
              config: QuillSimpleToolbarConfig(
                showFontFamily: false,
                showFontSize: false,
                multiRowsDisplay: false,
                showSearchButton: false,
                showLink: true,
                showCodeBlock: true,
                showQuote: true,
                showIndent: true,
                showListNumbers: true,
                showListBullets: true,
                showListCheck: true,
                showSubscript: true,
                showSuperscript: true,
                showHeaderStyle: true,
                showLineHeightButton: false,
                showInlineCode: true,
                showAlignmentButtons: true,
                showColorButton: true,
                showBackgroundColorButton: true,
                showStrikeThrough: true,
                showUnderLineButton: true,
                showClearFormat: true,
                customButtons: [
                  QuillToolbarCustomButtonOptions(
                    icon: const Icon(Icons.access_time_outlined, size: 20),
                    tooltip: l10n.insertTimestampTooltip,
                    onPressed: _insertTimestamp,
                  ),
                  QuillToolbarCustomButtonOptions(
                    icon: const Icon(Icons.horizontal_rule_outlined, size: 20),
                    tooltip: l10n.insertHorizontalRuleTooltip,
                    onPressed: _insertHorizontalRule,
                  ),
                  QuillToolbarCustomButtonOptions(
                    icon: const Icon(Icons.emoji_symbols_outlined, size: 20),
                    tooltip: l10n.insertSpecialCharTooltip,
                    onPressed: _openSpecialCharacters,
                  ),
                ],
              ),
            ),
          ],
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
                  checkBoxReadOnly: isReadOnly,
                  onTapUp: (details, getPosition) {
                    if (isReadOnly) return false;
                    final pos = getPosition(details.globalPosition);
                    CherrytreeCheckboxToggle.tryToggleAtTapOffset(
                      _quill,
                      pos.offset,
                    );
                    return false;
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
