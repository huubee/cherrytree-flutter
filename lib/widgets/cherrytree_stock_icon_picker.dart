import 'package:flutter/material.dart';

import '../cherrytree/cherrytree_stock_icon_names.dart';
import '../cherrytree/cherrytree_stock_icons.dart';

/// Modal dialog allowing the user to select an icon from CherryTree's 260+ stock icons.
class CherrytreeStockIconPicker extends StatefulWidget {
  const CherrytreeStockIconPicker({
    super.key,
    required this.selectedIconId,
  });

  final int selectedIconId;

  static Future<int?> show(BuildContext context, {required int selectedIconId}) {
    return showDialog<int>(
      context: context,
      builder: (ctx) => CherrytreeStockIconPicker(selectedIconId: selectedIconId),
    );
  }

  @override
  State<CherrytreeStockIconPicker> createState() =>
      _CherrytreeStockIconPickerState();
}

class _CherrytreeStockIconPickerState extends State<CherrytreeStockIconPicker> {
  final TextEditingController _filter = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _filter.addListener(() {
      setState(() => _query = _filter.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _filter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final entries = <int>[];
    for (var i = 1; i < kCherrytreeStockIconNames.length; i++) {
      final name = kCherrytreeStockIconNames[i];
      if (name == null) continue;
      if (_query.isEmpty || name.toLowerCase().contains(_query)) {
        entries.add(i);
      }
    }

    return AlertDialog(
      title: const Text('Select Node Icon'),
      content: SizedBox(
        width: 480,
        height: 420,
        child: Column(
          children: [
            TextField(
              controller: _filter,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search icons...',
                isDense: true,
                border: const OutlineInputBorder(),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _filter.clear(),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: entries.length + 1,
                itemBuilder: (ctx, index) {
                  if (index == 0) {
                    final isSel = widget.selectedIconId == 0;
                    return InkWell(
                      onTap: () => Navigator.pop(ctx, 0),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSel
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outlineVariant,
                            width: isSel ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.block,
                              size: 24,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'None',
                              style: theme.textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final iconId = entries[index - 1];
                  final isSel = widget.selectedIconId == iconId;
                  final iconName = kCherrytreeStockIconNames[iconId] ?? '';

                  return Tooltip(
                    message: iconName,
                    child: InkWell(
                      onTap: () => Navigator.pop(ctx, iconId),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSel
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outlineVariant,
                            width: isSel ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: isSel
                              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                              : null,
                        ),
                        padding: const EdgeInsets.all(6),
                        child: Center(
                          child: CherrytreeStockIcons.treeIconForNode(
                            customIconId: iconId,
                            treeDepth: 0,
                            size: 28,
                            fallback: const Icon(Icons.image, size: 28),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
