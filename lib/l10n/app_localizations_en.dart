// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Cherrytree Flutter';

  @override
  String get loading => 'Loading…';

  @override
  String get saveFailed =>
      'Could not save notes. Check storage permissions and free space.';

  @override
  String errorWithMessage(String error) {
    return 'Error: $error';
  }

  @override
  String get addRootNoteTooltip => 'Add root note';

  @override
  String get drawerNotesTitle => 'Notes';

  @override
  String get menuAddChild => 'Add child';

  @override
  String get menuDeleteSubtree => 'Delete subtree';

  @override
  String get untitledNote => 'Untitled';

  @override
  String get emptyEditorHint => 'Select a note or add one.';

  @override
  String get fieldTitle => 'Title';

  @override
  String get fieldBody => 'Body';

  @override
  String get newNoteTitle => 'New note';

  @override
  String get seedWelcomeTitle => 'Welcome';

  @override
  String get seedWelcomeBody =>
      'This is Spike A: a local tree of notes. Edit titles and body text; add nodes from the + menu. Data is saved on this device only — CherryTree file import comes later.';
}
