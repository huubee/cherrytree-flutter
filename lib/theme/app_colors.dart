import 'package:flutter/material.dart';

/// Brand and semantic colors. Prefer [Theme.of(context).colorScheme] in widgets;
/// use these when defining the seed [ThemeData] or for one-off accents.
abstract final class AppColors {
  /// Primary brand tone (cherry / wood); drives [ColorScheme.fromSeed].
  static const Color seed = Color(0xFF8B4513);
}
