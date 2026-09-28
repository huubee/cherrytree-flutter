import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Upstream CherryTree default special characters string (`CtConst::SPECIAL_CHARS_DEFAULT`).
const String kCherryTreeSpecialCharacters =
    '“”„‘’•◇▪▸☐☑☒★…‰€©®™°↓↑→←↔↵⇓⇑⇒⇐⇔»«▼▲►◄≤≥≠≈±¹²³½¼⅛×÷∞ø∑σ√∫ΔδΠπΣΦΩωαβγεηλμ☺☻☼♥♣♦✔♀♂♪♫✝';

/// Interactive symbol palette dialog matching CherryTree's Special Characters table.
class SpecialCharactersDialog extends StatelessWidget {
  const SpecialCharactersDialog({
    super.key,
    required this.onSelectCharacter,
    this.characters = kCherryTreeSpecialCharacters,
  });

  final ValueChanged<String> onSelectCharacter;
  final String characters;

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<String> onSelectCharacter,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => SpecialCharactersDialog(
        onSelectCharacter: onSelectCharacter,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final chars = characters.characters.toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 440),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.emoji_symbols_outlined, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    l10n.specialCharsTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 16),

              // Symbols grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 44,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  itemCount: chars.length,
                  itemBuilder: (ctx, index) {
                    final char = chars[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () {
                        onSelectCharacter(char);
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          char,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 18,
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
      ),
    );
  }
}
