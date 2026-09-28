// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

import '../cherrytree/cherrytree_stock_icons.dart';
import '../cherrytree/ct_constants.dart';
import '../models/note_document.dart';
import 'cherrytree_stock_icon_picker.dart';

/// Interactive node properties dialog mirroring upstream CherryTree's `node_prop_dialog`.
class NodePropertiesDialog extends StatefulWidget {
  const NodePropertiesDialog({
    super.key,
    required this.node,
  });

  final NoteNode node;

  static Future<bool?> show(BuildContext context, {required NoteNode node}) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => NodePropertiesDialog(node: node),
    );
  }

  @override
  State<NodePropertiesDialog> createState() => _NodePropertiesDialogState();
}

class _NodePropertiesDialogState extends State<NodePropertiesDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _tagsController;

  late bool _isBold;
  late bool _useColor;
  late String _currentColorHex;
  late int _customIconId;
  late String _syntax;
  late bool _isReadOnly;
  late bool _excludeMeFromSearch;
  late bool _excludeChildrenFromSearch;

  static const List<String> _colorPalette = [
    '#d32f2f', // red
    '#c2185b', // pink
    '#7b1fa2', // purple
    '#512da8', // deep purple
    '#303f9f', // indigo
    '#1976d2', // blue
    '#0288d1', // light blue
    '#0097a7', // cyan
    '#00796b', // teal
    '#388e3c', // green
    '#689f38', // light green
    '#afb42b', // lime
    '#fbc02d', // yellow
    '#ffa000', // amber
    '#f57c00', // orange
    '#e64a19', // deep orange
    '#5d4037', // brown
    '#616161', // grey
  ];

  static const List<String> _commonLanguages = [
    'python',
    'sh',
    'cpp',
    'c',
    'markdown',
    'sql',
    'html',
    'css',
    'javascript',
    'json',
    'xml',
    'yaml',
    'dart',
    'rust',
    'go',
    'java',
  ];

  @override
  void initState() {
    super.initState();
    final n = widget.node;
    _titleController = TextEditingController(text: n.title);
    _tagsController = TextEditingController(text: n.tags);

    _isBold = n.isBold;
    _currentColorHex = n.foregroundColor ?? '#1976d2';
    _useColor = n.foregroundColor != null && n.foregroundColor!.isNotEmpty;
    _customIconId = n.customIconId;
    _syntax = n.syntax.isNotEmpty ? n.syntax : kCherrytreeRichTextSyntaxId;
    _isReadOnly = n.isReadOnly;
    _excludeMeFromSearch = n.excludeMeFromSearch;
    _excludeChildrenFromSearch = n.excludeChildrenFromSearch;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  String _formatTimestamp(int ts) {
    if (ts <= 0) return 'Not recorded';
    final dt = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
    return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} - ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Color _parseHexColor(String hex) {
    var c = hex.trim();
    if (c.startsWith('#')) c = c.substring(1);
    final val = int.tryParse(c, radix: 16);
    return Color(0xff000000 | (val ?? 0x1976d2));
  }

  void _save() {
    final n = widget.node;
    n.title = _titleController.text.trim();
    n.tags = _tagsController.text.trim();
    n.isBold = _isBold;
    n.foregroundColor = _useColor ? _currentColorHex : null;
    n.customIconId = _customIconId;
    n.syntax = _syntax;
    n.isReadOnly = _isReadOnly;
    n.excludeMeFromSearch = _excludeMeFromSearch;
    n.excludeChildrenFromSearch = _excludeChildrenFromSearch;
    n.tsLastSave = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final n = widget.node;

    return AlertDialog(
      title: const Text('Node Properties'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Node Name',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),

              // Visual styling frame
              Text(
                'Tree Label Styling',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              CheckboxListTile(
                value: _isBold,
                title: const Text('Bold node name in tree'),
                dense: true,
                contentPadding: EdgeInsets.zero,
                onChanged: (v) => setState(() => _isBold = v ?? false),
              ),
              Row(
                children: [
                  Checkbox(
                    value: _useColor,
                    onChanged: (v) => setState(() => _useColor = v ?? false),
                  ),
                  const Text('Custom Color:'),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _useColor ? _pickColor : null,
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: _useColor
                            ? _parseHexColor(_currentColorHex)
                            : theme.colorScheme.outlineVariant,
                        border: Border.all(color: theme.colorScheme.outline),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_useColor)
                    Text(
                      _currentColorHex,
                      style: theme.textTheme.bodySmall,
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const SizedBox(width: 12),
                  const Text('Node Icon:'),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: _pickIcon,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colorScheme.outline),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CherrytreeStockIcons.treeIconForNode(
                            customIconId: _customIconId,
                            treeDepth: 0,
                            size: 22,
                            fallback: const Icon(Icons.description, size: 22),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _customIconId == 0
                                ? 'Default Icon'
                                : 'Icon #$_customIconId',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const Icon(Icons.arrow_drop_down, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const Divider(height: 28),

              // Node type frame
              Text(
                'Node Type',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              RadioListTile<String>(
                value: kCherrytreeRichTextSyntaxId,
                groupValue: _syntax == kCherrytreePlainTextSyntaxId ||
                        _commonLanguages.contains(_syntax)
                    ? _syntax
                    : kCherrytreeRichTextSyntaxId,
                title: const Text('Rich Text'),
                dense: true,
                contentPadding: EdgeInsets.zero,
                onChanged: (v) {
                  if (v != null) setState(() => _syntax = v);
                },
              ),
              RadioListTile<String>(
                value: kCherrytreePlainTextSyntaxId,
                groupValue: _syntax,
                title: const Text('Plain Text'),
                dense: true,
                contentPadding: EdgeInsets.zero,
                onChanged: (v) {
                  if (v != null) setState(() => _syntax = v);
                },
              ),
              Row(
                children: [
                  Radio<String>(
                    value: 'code',
                    groupValue: _commonLanguages.contains(_syntax) ? 'code' : null,
                    onChanged: (v) {
                      setState(() => _syntax = 'python');
                    },
                  ),
                  const Text('Code:'),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _commonLanguages.contains(_syntax) ? _syntax : 'python',
                    isDense: true,
                    items: _commonLanguages
                        .map(
                          (lang) => DropdownMenuItem(
                            value: lang,
                            child: Text(lang),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => _syntax = v);
                      }
                    },
                  ),
                ],
              ),

              const Divider(height: 28),

              // Tags
              TextField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (comma separated)',
                  hintText: 'e.g. todo, project, docs',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),

              const SizedBox(height: 12),

              // Search exclusions
              CheckboxListTile(
                value: _excludeMeFromSearch,
                title: const Text('Exclude this node from search'),
                dense: true,
                contentPadding: EdgeInsets.zero,
                onChanged: (v) =>
                    setState(() => _excludeMeFromSearch = v ?? false),
              ),
              CheckboxListTile(
                value: _excludeChildrenFromSearch,
                title: const Text('Exclude subnodes from search'),
                dense: true,
                contentPadding: EdgeInsets.zero,
                onChanged: (v) =>
                    setState(() => _excludeChildrenFromSearch = v ?? false),
              ),
              CheckboxListTile(
                value: _isReadOnly,
                title: const Text('Read Only (protect against editing)'),
                dense: true,
                contentPadding: EdgeInsets.zero,
                onChanged: (v) => setState(() => _isReadOnly = v ?? false),
              ),

              const Divider(height: 28),

              // Metadata info
              Text(
                'Metadata Info',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Node ID: ${n.id}',
                style: theme.textTheme.bodySmall,
              ),
              Text(
                'Created: ${_formatTimestamp(n.tsCreation)}',
                style: theme.textTheme.bodySmall,
              ),
              Text(
                'Last modified: ${_formatTimestamp(n.tsLastSave)}',
                style: theme.textTheme.bodySmall,
              ),
              if (n.masterId > 0)
                Text(
                  'Shared Master ID: ${n.masterId}',
                  style: theme.textTheme.bodySmall,
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _pickColor() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Color'),
        content: SizedBox(
          width: 300,
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _colorPalette.map((hex) {
              final color = _parseHexColor(hex);
              final isSel = _currentColorHex.toLowerCase() == hex.toLowerCase();
              return InkWell(
                onTap: () => Navigator.pop(ctx, hex),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color,
                    border: Border.all(
                      color: isSel ? Colors.white : Colors.transparent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      if (isSel)
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    if (selected != null && mounted) {
      setState(() => _currentColorHex = selected);
    }
  }

  Future<void> _pickIcon() async {
    final iconId = await CherrytreeStockIconPicker.show(
      context,
      selectedIconId: _customIconId,
    );
    if (iconId != null && mounted) {
      setState(() => _customIconId = iconId);
    }
  }
}
