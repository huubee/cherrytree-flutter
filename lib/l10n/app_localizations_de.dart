// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Cherrytree Flutter';

  @override
  String get loading => 'Wird geladen…';

  @override
  String get saveFailed =>
      'Notizen konnten nicht gespeichert werden. Speicher prüfen.';

  @override
  String errorWithMessage(String error) {
    return 'Fehler: $error';
  }

  @override
  String get addRootNoteTooltip => 'Hauptnotiz hinzufügen';

  @override
  String get drawerNotesTitle => 'Notizen';

  @override
  String get menuAddChild => 'Unterpunkt hinzufügen';

  @override
  String get menuDeleteSubtree => 'Zweig löschen';

  @override
  String get untitledNote => 'Ohne Titel';

  @override
  String get emptyEditorHint => 'Notiz auswählen oder neue anlegen.';

  @override
  String get fieldTitle => 'Titel';

  @override
  String get fieldBody => 'Text';

  @override
  String get newNoteTitle => 'Neue Notiz';

  @override
  String get seedWelcomeTitle => 'Willkommen';

  @override
  String get seedWelcomeBody =>
      'Dies ist Spike A: ein lokaler Notizbaum. Bearbeiten Sie Titel und Text; fügen Sie Notizen über das +-Menü hinzu. Daten werden nur auf diesem Gerät gespeichert — Import von CherryTree-Dateien folgt später.';
}
