import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ca.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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
    Locale('ca'),
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ca, this message translates to:
  /// **'MeteoGarden'**
  String get appTitle;

  /// No description provided for @loginWelcomeTitle.
  ///
  /// In ca, this message translates to:
  /// **'Benvinguda a MeteoGarden'**
  String get loginWelcomeTitle;

  /// No description provided for @loginWelcomeSubtitle.
  ///
  /// In ca, this message translates to:
  /// **'Inicia sessió per continuar cuidant el teu jardí.'**
  String get loginWelcomeSubtitle;

  /// No description provided for @loginUsernameLabel.
  ///
  /// In ca, this message translates to:
  /// **'Nom d\'usuari'**
  String get loginUsernameLabel;

  /// No description provided for @loginUsernameHint.
  ///
  /// In ca, this message translates to:
  /// **'Introdueix el teu nom d\'usuari'**
  String get loginUsernameHint;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In ca, this message translates to:
  /// **'Contrasenya'**
  String get loginPasswordLabel;

  /// No description provided for @loginPasswordHint.
  ///
  /// In ca, this message translates to:
  /// **'Introdueix la teva contrasenya'**
  String get loginPasswordHint;

  /// No description provided for @loginButton.
  ///
  /// In ca, this message translates to:
  /// **'Iniciar sessió'**
  String get loginButton;

  /// No description provided for @loginContinueWith.
  ///
  /// In ca, this message translates to:
  /// **'o continuar amb'**
  String get loginContinueWith;

  /// No description provided for @loginNoAccount.
  ///
  /// In ca, this message translates to:
  /// **'No tens compte?'**
  String get loginNoAccount;

  /// No description provided for @loginCreateAccount.
  ///
  /// In ca, this message translates to:
  /// **'Crear compte'**
  String get loginCreateAccount;

  /// No description provided for @loginError.
  ///
  /// In ca, this message translates to:
  /// **'Error de login'**
  String get loginError;

  /// No description provided for @loginGoogleError.
  ///
  /// In ca, this message translates to:
  /// **'Error login Google'**
  String get loginGoogleError;

  /// No description provided for @profileLoadError.
  ///
  /// In ca, this message translates to:
  /// **'No s\'ha pogut carregar el perfil'**
  String get profileLoadError;

  /// No description provided for @navGarden.
  ///
  /// In ca, this message translates to:
  /// **'Jardí'**
  String get navGarden;

  /// No description provided for @navFriends.
  ///
  /// In ca, this message translates to:
  /// **'Amics'**
  String get navFriends;

  /// No description provided for @navCamera.
  ///
  /// In ca, this message translates to:
  /// **'Càmera'**
  String get navCamera;

  /// No description provided for @navMissions.
  ///
  /// In ca, this message translates to:
  /// **'Missions'**
  String get navMissions;

  /// No description provided for @navProfile.
  ///
  /// In ca, this message translates to:
  /// **'Perfil'**
  String get navProfile;

  /// No description provided for @commonLanguage.
  ///
  /// In ca, this message translates to:
  /// **'Idioma'**
  String get commonLanguage;

  /// No description provided for @commonCity.
  ///
  /// In ca, this message translates to:
  /// **'Ciutat'**
  String get commonCity;

  /// No description provided for @commonContinue.
  ///
  /// In ca, this message translates to:
  /// **'Continuar'**
  String get commonContinue;
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
      <String>['ca', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ca':
      return AppLocalizationsCa();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
