import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// Result from [InsertCodeboxDialog].
class CodeboxInsertResult {
  final String language;
  final String code;
  final bool showLineNumbers;

  const CodeboxInsertResult({
    required this.language,
    required this.code,
    required this.showLineNumbers,
  });
}

/// Dialog to configure and insert a codebox into the note editor.
class InsertCodeboxDialog extends StatefulWidget {
  const InsertCodeboxDialog({super.key});

  static Future<CodeboxInsertResult?> show(BuildContext context) {
    return showDialog<CodeboxInsertResult>(
      context: context,
      builder: (ctx) => const InsertCodeboxDialog(),
    );
  }

  @override
  State<InsertCodeboxDialog> createState() => _InsertCodeboxDialogState();
}

class _InsertCodeboxDialogState extends State<InsertCodeboxDialog> {
  static const List<String> _languages = [
    'python',
    'dart',
    'cpp',
    'c',
    'javascript',
    'typescript',
    'sh',
    'bash',
    'html',
    'xml',
    'json',
    'css',
    'sql',
    'markdown',
    'java',
    'rust',
    'go',
    'php',
  ];

  late String _language;
  bool _showLineNumbers = true;
  late final TextEditingController _codeController;

  @override
  void initState() {
    super.initState();
    _language = 'python';
    _codeController = TextEditingController();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 560),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Row(
                children: [
                  Icon(Icons.terminal_outlined, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    l10n.codeboxDialogTitle,
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

              // Language selector and line numbers toggle
              Wrap(
                spacing: 16,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${l10n.codeboxLanguageLabel}:', style: theme.textTheme.bodyMedium),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: _language,
                        items: _languages
                            .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _language = val);
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: _showLineNumbers,
                        onChanged: (val) => setState(() => _showLineNumbers = val ?? true),
                      ),
                      const Text('Line numbers'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Code text area
              Text(l10n.codeboxCodeLabel, style: theme.textTheme.labelMedium),
              const SizedBox(height: 6),
              Expanded(
                child: TextField(
                  controller: _codeController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                  ),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'print("Hello CherryTree!")',
                    fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    filled: true,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop(
                        CodeboxInsertResult(
                          language: _language,
                          code: _codeController.text,
                          showLineNumbers: _showLineNumbers,
                        ),
                      );
                    },
                    child: const Text('Insert'),
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
