import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// Dialog to configure row/column count and generate a table into the note editor.
class InsertTableDialog extends StatefulWidget {
  const InsertTableDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (ctx) => const InsertTableDialog(),
    );
  }

  @override
  State<InsertTableDialog> createState() => _InsertTableDialogState();
}

class _InsertTableDialogState extends State<InsertTableDialog> {
  int _cols = 3;
  int _rows = 3;
  bool _hasHeader = true;

  String _generateMarkdownTable() {
    final buffer = StringBuffer('\n');

    if (_hasHeader) {
      final headerCols = List.generate(_cols, (i) => 'Col ${i + 1}');
      buffer.writeln('| ${headerCols.join(' | ')} |');
      final sepCols = List.generate(_cols, (_) => '---');
      buffer.writeln('| ${sepCols.join(' | ')} |');
    }

    final dataRows = _hasHeader ? _rows - 1 : _rows;
    for (var r = 0; r < (dataRows <= 0 ? 1 : dataRows); r++) {
      final cells = List.generate(_cols, (c) => 'Item ${r * _cols + c + 1}');
      buffer.writeln('| ${cells.join(' | ')} |');
    }
    buffer.writeln();
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.table_chart_outlined, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(l10n.insertTableTooltip),
        ],
      ),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(child: Text('Columns:')),
                DropdownButton<int>(
                  value: _cols,
                  items: [1, 2, 3, 4, 5, 6, 7, 8]
                      .map((c) => DropdownMenuItem(value: c, child: Text('$c')))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _cols = val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Expanded(child: Text('Rows:')),
                DropdownButton<int>(
                  value: _rows,
                  items: [1, 2, 3, 4, 5, 6, 7, 8, 10, 12]
                      .map((r) => DropdownMenuItem(value: r, child: Text('$r')))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _rows = val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Header row'),
              value: _hasHeader,
              onChanged: (val) => setState(() => _hasHeader = val ?? true),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_generateMarkdownTable()),
          child: const Text('Insert'),
        ),
      ],
    );
  }
}
