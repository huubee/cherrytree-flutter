import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'notes_home_page.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CherrytreeFlutterApp());
}

class CherrytreeFlutterApp extends StatelessWidget {
  const CherrytreeFlutterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light(),
      home: const NotesHomePage(),
    );
  }
}
