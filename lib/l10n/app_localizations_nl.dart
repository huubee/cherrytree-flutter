// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'Cherrytree Flutter';

  @override
  String get loading => 'Laden…';

  @override
  String get saveFailed =>
      'Notities konden niet worden opgeslagen. Controleer opslag en vrije ruimte.';

  @override
  String errorWithMessage(String error) {
    return 'Fout: $error';
  }

  @override
  String get addRootNoteTooltip => 'Hoofdnotitie toevoegen';

  @override
  String get drawerNotesTitle => 'Notities';

  @override
  String get menuAddChild => 'Kind toevoegen';

  @override
  String get menuDeleteSubtree => 'Subboom verwijderen';

  @override
  String get untitledNote => 'Naamloos';

  @override
  String get emptyEditorHint => 'Selecteer een notitie of voeg er een toe.';

  @override
  String get fieldTitle => 'Titel';

  @override
  String get fieldBody => 'Tekst';

  @override
  String get newNoteTitle => 'Nieuwe notitie';

  @override
  String get seedWelcomeTitle => 'Welkom';

  @override
  String get seedWelcomeBody =>
      'Dit is Spike A: een lokale boom van notities. Bewerk titels en tekst; voeg notities toe via het +-menu. Gegevens worden alleen op dit apparaat opgeslagen — import van CherryTree-bestanden volgt later.';
}
