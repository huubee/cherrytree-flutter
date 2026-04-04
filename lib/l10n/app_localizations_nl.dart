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
      'Spike B: lokale notities met alleen-lezen import van onversleutelde CherryTree .ctd (XML) en .ctb (SQLite). Rijke tekst wordt als platte tekst getoond; afbeeldingen en tabellen worden weggelaten.';

  @override
  String get importCherryTreeTooltip => 'CherryTree-bestand importeren';

  @override
  String get importReplaceTitle => 'Lokale notities vervangen?';

  @override
  String get importReplaceMessage =>
      'Dit vervangt alle in deze app opgeslagen notities door het geïmporteerde CherryTree-document. Doorgaan?';

  @override
  String get importCancel => 'Annuleren';

  @override
  String get importReplaceConfirm => 'Vervangen';

  @override
  String get importEncryptedError =>
      'Versleutelde CherryTree-documenten (.ctz / .ctx) worden nog niet ondersteund.';

  @override
  String get importUnsupportedFileType =>
      'Kies een CherryTree-.ctd- of .ctb-bestand.';

  @override
  String importFailedMessage(String error) {
    return 'Importeren mislukt: $error';
  }

  @override
  String get importWarningsTitle => 'Opmerkingen bij import';

  @override
  String get importWarningsOk => 'OK';

  @override
  String get themeUseLight => 'Licht thema';

  @override
  String get themeUseDark => 'Donker thema';

  @override
  String get settingsTitle => 'Instellingen';

  @override
  String get settingsTooltip => 'Instellingen';

  @override
  String get settingsAppearanceSection => 'Weergave';

  @override
  String get settingsUseDarkTheme => 'Donker thema';

  @override
  String get settingsUseDarkThemeSubtitle =>
      'Donkerblauw, vergelijkbaar met desktop CherryTree';
}
