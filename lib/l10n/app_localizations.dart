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

  /// No description provided for @albumTitle.
  ///
  /// In ca, this message translates to:
  /// **'El meu àlbum de plantes'**
  String get albumTitle;

  /// No description provided for @albumLoadingEncyclopedia.
  ///
  /// In ca, this message translates to:
  /// **'Consultant enciclopèdia...'**
  String get albumLoadingEncyclopedia;

  /// No description provided for @albumDetailsLoadError.
  ///
  /// In ca, this message translates to:
  /// **'Error carregant detalls: {error}'**
  String albumDetailsLoadError(String error);

  /// No description provided for @albumUnknownPlant.
  ///
  /// In ca, this message translates to:
  /// **'Desconeguda'**
  String get albumUnknownPlant;

  /// No description provided for @albumNoDescription.
  ///
  /// In ca, this message translates to:
  /// **'No hi ha descripció disponible.'**
  String get albumNoDescription;

  /// No description provided for @albumFamilyLabel.
  ///
  /// In ca, this message translates to:
  /// **'Família'**
  String get albumFamilyLabel;

  /// No description provided for @albumBlooms.
  ///
  /// In ca, this message translates to:
  /// **'Floreix'**
  String get albumBlooms;

  /// No description provided for @albumDoesNotBloom.
  ///
  /// In ca, this message translates to:
  /// **'No floreix'**
  String get albumDoesNotBloom;

  /// No description provided for @albumDescriptionTitle.
  ///
  /// In ca, this message translates to:
  /// **'Descripció'**
  String get albumDescriptionTitle;

  /// No description provided for @commonClose.
  ///
  /// In ca, this message translates to:
  /// **'Tancar'**
  String get commonClose;

  /// No description provided for @albumEmptyState.
  ///
  /// In ca, this message translates to:
  /// **'Encara no has descobert cap planta 🌱\nContinua explorant!'**
  String get albumEmptyState;

  /// No description provided for @albumPlantInfoLoadError.
  ///
  /// In ca, this message translates to:
  /// **'Error carregant la informació de la planta'**
  String get albumPlantInfoLoadError;

  /// No description provided for @commonBack.
  ///
  /// In ca, this message translates to:
  /// **'Tornar'**
  String get commonBack;

  /// No description provided for @shopTitle.
  ///
  /// In ca, this message translates to:
  /// **'Botiga'**
  String get shopTitle;

  /// No description provided for @shopSeedsTab.
  ///
  /// In ca, this message translates to:
  /// **'Llavors 🌱'**
  String get shopSeedsTab;

  /// No description provided for @shopOtherTab.
  ///
  /// In ca, this message translates to:
  /// **'Altres 🛒'**
  String get shopOtherTab;

  /// No description provided for @shopLoadError.
  ///
  /// In ca, this message translates to:
  /// **'No s\'han pogut carregar els productes.'**
  String get shopLoadError;

  /// No description provided for @shopConnectionError.
  ///
  /// In ca, this message translates to:
  /// **'Error de connexió o processant les dades.'**
  String get shopConnectionError;

  /// No description provided for @shopPurchaseProcessingError.
  ///
  /// In ca, this message translates to:
  /// **'Error en processar la compra.'**
  String get shopPurchaseProcessingError;

  /// No description provided for @shopPurchaseSuccess.
  ///
  /// In ca, this message translates to:
  /// **'Compra realitzada amb èxit! 🌱'**
  String get shopPurchaseSuccess;

  /// No description provided for @shopDescriptionTitle.
  ///
  /// In ca, this message translates to:
  /// **'Descripció'**
  String get shopDescriptionTitle;

  /// No description provided for @shopTotalPrice.
  ///
  /// In ca, this message translates to:
  /// **'Preu total:'**
  String get shopTotalPrice;

  /// No description provided for @shopBuyButton.
  ///
  /// In ca, this message translates to:
  /// **'Comprar'**
  String get shopBuyButton;

  /// No description provided for @shopNoItemsAvailable.
  ///
  /// In ca, this message translates to:
  /// **'No hi ha articles disponibles ara mateix.'**
  String get shopNoItemsAvailable;

  /// No description provided for @calendarRetry.
  ///
  /// In ca, this message translates to:
  /// **'Reintentar'**
  String get calendarRetry;

  /// No description provided for @calendarUpcomingEvents.
  ///
  /// In ca, this message translates to:
  /// **'Propers esdeveniments'**
  String get calendarUpcomingEvents;

  /// No description provided for @calendarNoEventsThisMonth.
  ///
  /// In ca, this message translates to:
  /// **'No hi ha esdeveniments aquest mes'**
  String get calendarNoEventsThisMonth;

  /// No description provided for @calendarClearFilters.
  ///
  /// In ca, this message translates to:
  /// **'Eliminar filtres'**
  String get calendarClearFilters;

  /// No description provided for @calendarNoEventsThisDay.
  ///
  /// In ca, this message translates to:
  /// **'Sense esdeveniments aquest dia'**
  String get calendarNoEventsThisDay;

  /// No description provided for @calendarFiltersTitle.
  ///
  /// In ca, this message translates to:
  /// **'Filtres'**
  String get calendarFiltersTitle;

  /// No description provided for @calendarClearAll.
  ///
  /// In ca, this message translates to:
  /// **'Netejar tot'**
  String get calendarClearAll;

  /// No description provided for @calendarSearchTextLabel.
  ///
  /// In ca, this message translates to:
  /// **'Cerca per text'**
  String get calendarSearchTextLabel;

  /// No description provided for @calendarSearchTextHint.
  ///
  /// In ca, this message translates to:
  /// **'Nom, descripció...'**
  String get calendarSearchTextHint;

  /// No description provided for @calendarCityLabel.
  ///
  /// In ca, this message translates to:
  /// **'Ciutat'**
  String get calendarCityLabel;

  /// No description provided for @calendarCityHint.
  ///
  /// In ca, this message translates to:
  /// **'Barcelona, Girona...'**
  String get calendarCityHint;

  /// No description provided for @calendarCountyLabel.
  ///
  /// In ca, this message translates to:
  /// **'Comarca'**
  String get calendarCountyLabel;

  /// No description provided for @calendarCountyHint.
  ///
  /// In ca, this message translates to:
  /// **'Osona, Maresme...'**
  String get calendarCountyHint;

  /// No description provided for @calendarCategoryLabel.
  ///
  /// In ca, this message translates to:
  /// **'Categoria'**
  String get calendarCategoryLabel;

  /// No description provided for @calendarCategoryHint.
  ///
  /// In ca, this message translates to:
  /// **'Mercat, Concert, Ruta...'**
  String get calendarCategoryHint;

  /// No description provided for @calendarMaxDistanceLabel.
  ///
  /// In ca, this message translates to:
  /// **'Distància màxima'**
  String get calendarMaxDistanceLabel;

  /// No description provided for @calendarMaxPriceLabel.
  ///
  /// In ca, this message translates to:
  /// **'Preu màxim'**
  String get calendarMaxPriceLabel;

  /// No description provided for @calendarApplyFilters.
  ///
  /// In ca, this message translates to:
  /// **'Aplicar filtres'**
  String get calendarApplyFilters;

  /// No description provided for @calendarFree.
  ///
  /// In ca, this message translates to:
  /// **'Gratis'**
  String get calendarFree;

  /// No description provided for @calendarFreeAccent.
  ///
  /// In ca, this message translates to:
  /// **'Gratuït'**
  String get calendarFreeAccent;

  /// No description provided for @calendarBuyTickets.
  ///
  /// In ca, this message translates to:
  /// **'Comprar entrades'**
  String get calendarBuyTickets;

  /// No description provided for @calendarEventSingular.
  ///
  /// In ca, this message translates to:
  /// **'esdeveniment'**
  String get calendarEventSingular;

  /// No description provided for @calendarEventPlural.
  ///
  /// In ca, this message translates to:
  /// **'esdeveniments'**
  String get calendarEventPlural;

  /// No description provided for @calendarEventsCount.
  ///
  /// In ca, this message translates to:
  /// **'{count} esdeveniments'**
  String calendarEventsCount(Object count);

  /// No description provided for @calendarSelectedDaySummary.
  ///
  /// In ca, this message translates to:
  /// **'{day} {month} · {count} {eventWord}'**
  String calendarSelectedDaySummary(
    Object day,
    Object month,
    Object count,
    Object eventWord,
  );

  /// No description provided for @calendarMaxDistanceChip.
  ///
  /// In ca, this message translates to:
  /// **'≤{km} km'**
  String calendarMaxDistanceChip(Object km);

  /// No description provided for @calendarMaxPriceChip.
  ///
  /// In ca, this message translates to:
  /// **'≤{price}€'**
  String calendarMaxPriceChip(Object price);

  /// No description provided for @calendarSearchChip.
  ///
  /// In ca, this message translates to:
  /// **'\"{query}\"'**
  String calendarSearchChip(Object query);

  /// No description provided for @calendarDistanceKm.
  ///
  /// In ca, this message translates to:
  /// **'{km} km'**
  String calendarDistanceKm(Object km);

  /// No description provided for @calendarPriceEuros.
  ///
  /// In ca, this message translates to:
  /// **'{price} €'**
  String calendarPriceEuros(Object price);

  /// No description provided for @calendarPriceCompact.
  ///
  /// In ca, this message translates to:
  /// **'{price}€'**
  String calendarPriceCompact(Object price);

  /// No description provided for @weekdayMon.
  ///
  /// In ca, this message translates to:
  /// **'Dl'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In ca, this message translates to:
  /// **'Dt'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In ca, this message translates to:
  /// **'Dc'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In ca, this message translates to:
  /// **'Dj'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In ca, this message translates to:
  /// **'Dv'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In ca, this message translates to:
  /// **'Ds'**
  String get weekdaySat;

  /// No description provided for @weekdaySun.
  ///
  /// In ca, this message translates to:
  /// **'Dg'**
  String get weekdaySun;

  /// No description provided for @monthJanuary.
  ///
  /// In ca, this message translates to:
  /// **'Gener'**
  String get monthJanuary;

  /// No description provided for @monthFebruary.
  ///
  /// In ca, this message translates to:
  /// **'Febrer'**
  String get monthFebruary;

  /// No description provided for @monthMarch.
  ///
  /// In ca, this message translates to:
  /// **'Març'**
  String get monthMarch;

  /// No description provided for @monthApril.
  ///
  /// In ca, this message translates to:
  /// **'Abril'**
  String get monthApril;

  /// No description provided for @monthMay.
  ///
  /// In ca, this message translates to:
  /// **'Maig'**
  String get monthMay;

  /// No description provided for @monthJune.
  ///
  /// In ca, this message translates to:
  /// **'Juny'**
  String get monthJune;

  /// No description provided for @monthJuly.
  ///
  /// In ca, this message translates to:
  /// **'Juliol'**
  String get monthJuly;

  /// No description provided for @monthAugust.
  ///
  /// In ca, this message translates to:
  /// **'Agost'**
  String get monthAugust;

  /// No description provided for @monthSeptember.
  ///
  /// In ca, this message translates to:
  /// **'Setembre'**
  String get monthSeptember;

  /// No description provided for @monthOctober.
  ///
  /// In ca, this message translates to:
  /// **'Octubre'**
  String get monthOctober;

  /// No description provided for @monthNovember.
  ///
  /// In ca, this message translates to:
  /// **'Novembre'**
  String get monthNovember;

  /// No description provided for @monthDecember.
  ///
  /// In ca, this message translates to:
  /// **'Desembre'**
  String get monthDecember;
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
