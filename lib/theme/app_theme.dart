import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Central place for [ThemeData]. Adjust typography and component themes here.
abstract final class AppTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: Brightness.light,
    );

    final base = ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
    );

    // Typography: tune in one place. Add `fontFamily` when you bundle fonts in pubspec.
    final textTheme = base.textTheme.copyWith(
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colorScheme.surfaceContainerHighest,
        foregroundColor: colorScheme.onSurface,
      ),
    );
  }
}
