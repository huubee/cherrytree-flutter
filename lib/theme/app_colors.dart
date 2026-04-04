import 'package:flutter/material.dart';

/// Brand and semantic colors. Prefer [Theme.of(context).colorScheme] in widgets;
/// use these when defining the seed [ThemeData] or for one-off accents.
abstract final class AppColors {
  /// Primary brand tone (cherry / wood); drives [ColorScheme.fromSeed].
  static const Color seed = Color(0xFF8B4513);

  /// Desktop CherryTree–style dark scaffold (navy, not pure black).
  static const Color darkScaffold = Color(0xFF0F1218);

  /// Slightly lifted surface for panels and text fields in dark mode.
  static const Color darkSurface = Color(0xFF171B24);
}
