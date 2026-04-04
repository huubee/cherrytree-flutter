import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/note_document.dart';
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
  late TextEditingController _body;

  static const double _bodyFontSize = 14;
  static const double _bodyLineHeight = 1.5;

  @override
  void initState() {
    super.initState();
    final n = widget.node;
    _title = TextEditingController(text: n?.title ?? '');
    _body = TextEditingController(text: n?.body ?? '');
  }

  @override
  void didUpdateWidget(covariant NodeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When the user selects a different note in the TreePanel, the parent passes a new NodeDocument down.
    // If we only relied on initState, the text controllers would retain the old note's text.
    if (oldWidget.node?.id != widget.node?.id) {
      _title.text = widget.node?.title ?? '';
      _body.text = widget.node?.body ?? '';
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
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

    final bodyStyle = theme.textTheme.bodyMedium?.copyWith(
      fontFamily: 'monospace',
      fontSize: _bodyFontSize,
      height: _bodyLineHeight,
    );

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
          Expanded(
            child: TextField(
              controller: _body,
              style: bodyStyle,
              strutStyle: StrutStyle(
                fontFamily: 'monospace',
                fontSize: _bodyFontSize,
                height: _bodyLineHeight,
                leadingDistribution: TextLeadingDistribution.even,
              ),
              decoration: InputDecoration(
                labelText: l10n.fieldBody,
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: bodyFill,
              ),
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              onChanged: (v) {
                n.body = v;
                widget.onChanged();
              },
            ),
          ),
        ],
      ),
    );
  }
}
