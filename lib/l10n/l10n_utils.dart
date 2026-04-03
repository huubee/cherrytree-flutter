import 'dart:ui';

import 'app_localizations.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_nl.dart';

/// Resolves [AppLocalizations] for the **device** locale without a [BuildContext].
/// Used for first-run seed content so it matches the user’s language when possible.
AppLocalizations appLocalizationsForDeviceLocale() {
  final code =
      PlatformDispatcher.instance.locale.languageCode.toLowerCase();
  switch (code) {
    case 'nl':
      return AppLocalizationsNl();
    case 'de':
      return AppLocalizationsDe();
    default:
      return AppLocalizationsEn();
  }
}
