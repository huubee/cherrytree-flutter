import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_nl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('nl'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Cherrytree Flutter'**
  String get appTitle;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save notes. Check storage permissions and free space.'**
  String get saveFailed;

  /// No description provided for @errorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorWithMessage(String error);

  /// No description provided for @addRootNoteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add root note'**
  String get addRootNoteTooltip;

  /// No description provided for @drawerNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get drawerNotesTitle;

  /// No description provided for @menuAddChild.
  ///
  /// In en, this message translates to:
  /// **'Add child'**
  String get menuAddChild;

  /// No description provided for @menuDeleteSubtree.
  ///
  /// In en, this message translates to:
  /// **'Delete subtree'**
  String get menuDeleteSubtree;

  /// No description provided for @untitledNote.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get untitledNote;

  /// No description provided for @emptyEditorHint.
  ///
  /// In en, this message translates to:
  /// **'Select a note or add one.'**
  String get emptyEditorHint;

  /// No description provided for @fieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get fieldTitle;

  /// No description provided for @fieldBody.
  ///
  /// In en, this message translates to:
  /// **'Body'**
  String get fieldBody;

  /// No description provided for @newNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'New note'**
  String get newNoteTitle;

  /// No description provided for @seedWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get seedWelcomeTitle;

  /// No description provided for @seedWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Spike B: local tree of notes with read-only import of unencrypted CherryTree .ctd (XML) and .ctb (SQLite) files. Rich text is shown as plain text; images and tables are omitted.'**
  String get seedWelcomeBody;

  /// No description provided for @importCherryTreeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Import CherryTree file'**
  String get importCherryTreeTooltip;

  /// No description provided for @importReplaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace local notes?'**
  String get importReplaceTitle;

  /// No description provided for @importReplaceMessage.
  ///
  /// In en, this message translates to:
  /// **'This replaces all notes stored in this app with the imported CherryTree document. Continue?'**
  String get importReplaceMessage;

  /// No description provided for @importCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get importCancel;

  /// No description provided for @importReplaceConfirm.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get importReplaceConfirm;

  /// No description provided for @importEncryptedError.
  ///
  /// In en, this message translates to:
  /// **'Encrypted CherryTree documents (.ctz / .ctx) are not supported yet.'**
  String get importEncryptedError;

  /// No description provided for @importUnsupportedFileType.
  ///
  /// In en, this message translates to:
  /// **'Please choose a CherryTree .ctd or .ctb file.'**
  String get importUnsupportedFileType;

  /// No description provided for @importFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Could not import: {error}'**
  String importFailedMessage(String error);

  /// No description provided for @importWarningsTitle.
  ///
  /// In en, this message translates to:
  /// **'Import notes'**
  String get importWarningsTitle;

  /// No description provided for @importWarningsOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get importWarningsOk;

  /// No description provided for @themeUseLight.
  ///
  /// In en, this message translates to:
  /// **'Use light theme'**
  String get themeUseLight;

  /// No description provided for @themeUseDark.
  ///
  /// In en, this message translates to:
  /// **'Use dark theme'**
  String get themeUseDark;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTooltip;

  /// No description provided for @settingsAppearanceSection.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearanceSection;

  /// No description provided for @settingsUseDarkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get settingsUseDarkTheme;

  /// No description provided for @settingsUseDarkThemeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Navy tones similar to desktop CherryTree'**
  String get settingsUseDarkThemeSubtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'nl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'nl':
      return AppLocalizationsNl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
