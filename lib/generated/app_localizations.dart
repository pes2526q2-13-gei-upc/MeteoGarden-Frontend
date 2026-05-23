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
/// import 'generated/app_localizations.dart';
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

  /// No description provided for @commonBack.
  ///
  /// In ca, this message translates to:
  /// **'Tornar'**
  String get commonBack;

  /// No description provided for @commonCancel.
  ///
  /// In ca, this message translates to:
  /// **'Cancel·lar'**
  String get commonCancel;

  /// No description provided for @commonCity.
  ///
  /// In ca, this message translates to:
  /// **'Ciutat'**
  String get commonCity;

  /// No description provided for @commonClose.
  ///
  /// In ca, this message translates to:
  /// **'Tancar'**
  String get commonClose;

  /// No description provided for @commonContinue.
  ///
  /// In ca, this message translates to:
  /// **'Continuar'**
  String get commonContinue;

  /// No description provided for @commonDescription.
  ///
  /// In ca, this message translates to:
  /// **'Descripció'**
  String get commonDescription;

  /// No description provided for @commonLanguage.
  ///
  /// In ca, this message translates to:
  /// **'Idioma'**
  String get commonLanguage;

  /// No description provided for @commonRetry.
  ///
  /// In ca, this message translates to:
  /// **'Reintentar'**
  String get commonRetry;

  /// No description provided for @commonSave.
  ///
  /// In ca, this message translates to:
  /// **'Guardar'**
  String get commonSave;

  /// No description provided for @commonSearch.
  ///
  /// In ca, this message translates to:
  /// **'Cerca'**
  String get commonSearch;

  /// No description provided for @commonEliminar.
  ///
  /// In ca, this message translates to:
  /// **'Eliminar'**
  String get commonEliminar;

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

  /// No description provided for @albumTitle.
  ///
  /// In ca, this message translates to:
  /// **'El meu àlbum de plantes'**
  String get albumTitle;

  /// No description provided for @albumDiscoveredPlants.
  ///
  /// In ca, this message translates to:
  /// **'Plantes descobertes'**
  String get albumDiscoveredPlants;

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

  /// No description provided for @albumNumber.
  ///
  /// In ca, this message translates to:
  /// **'plantes descobertes'**
  String get albumNumber;

  /// No description provided for @shopTitle.
  ///
  /// In ca, this message translates to:
  /// **'Botiga'**
  String get shopTitle;

  /// No description provided for @shopSeedsTab.
  ///
  /// In ca, this message translates to:
  /// **'Llavors'**
  String get shopSeedsTab;

  /// No description provided for @shopOtherTab.
  ///
  /// In ca, this message translates to:
  /// **'Altres'**
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

  /// No description provided for @monthShortJanuary.
  ///
  /// In ca, this message translates to:
  /// **'gen'**
  String get monthShortJanuary;

  /// No description provided for @monthShortFebruary.
  ///
  /// In ca, this message translates to:
  /// **'feb'**
  String get monthShortFebruary;

  /// No description provided for @monthShortMarch.
  ///
  /// In ca, this message translates to:
  /// **'març'**
  String get monthShortMarch;

  /// No description provided for @monthShortApril.
  ///
  /// In ca, this message translates to:
  /// **'abr'**
  String get monthShortApril;

  /// No description provided for @monthShortMay.
  ///
  /// In ca, this message translates to:
  /// **'maig'**
  String get monthShortMay;

  /// No description provided for @monthShortJune.
  ///
  /// In ca, this message translates to:
  /// **'juny'**
  String get monthShortJune;

  /// No description provided for @monthShortJuly.
  ///
  /// In ca, this message translates to:
  /// **'jul'**
  String get monthShortJuly;

  /// No description provided for @monthShortAugust.
  ///
  /// In ca, this message translates to:
  /// **'ago'**
  String get monthShortAugust;

  /// No description provided for @monthShortSeptember.
  ///
  /// In ca, this message translates to:
  /// **'set'**
  String get monthShortSeptember;

  /// No description provided for @monthShortOctober.
  ///
  /// In ca, this message translates to:
  /// **'oct'**
  String get monthShortOctober;

  /// No description provided for @monthShortNovember.
  ///
  /// In ca, this message translates to:
  /// **'nov'**
  String get monthShortNovember;

  /// No description provided for @monthShortDecember.
  ///
  /// In ca, this message translates to:
  /// **'des'**
  String get monthShortDecember;

  /// No description provided for @photoNoCameraAvailable.
  ///
  /// In ca, this message translates to:
  /// **'No s’ha trobat cap càmera disponible.'**
  String get photoNoCameraAvailable;

  /// No description provided for @photoCameraInitError.
  ///
  /// In ca, this message translates to:
  /// **'No s’ha pogut inicialitzar la càmera.'**
  String get photoCameraInitError;

  /// No description provided for @photoUnexpectedError.
  ///
  /// In ca, this message translates to:
  /// **'S’ha produït un error inesperat.'**
  String get photoUnexpectedError;

  /// No description provided for @photoTakePlantPicture.
  ///
  /// In ca, this message translates to:
  /// **'Fotografia la planta'**
  String get photoTakePlantPicture;

  /// No description provided for @photoTreeMode.
  ///
  /// In ca, this message translates to:
  /// **'Fulla'**
  String get photoTreeMode;

  /// No description provided for @photoFlowerMode.
  ///
  /// In ca, this message translates to:
  /// **'Flor'**
  String get photoFlowerMode;

  /// No description provided for @photoTreeModeSelected.
  ///
  /// In ca, this message translates to:
  /// **'Mode fulla seleccionat'**
  String get photoTreeModeSelected;

  /// No description provided for @photoFlowerModeSelected.
  ///
  /// In ca, this message translates to:
  /// **'Mode flor seleccionat'**
  String get photoFlowerModeSelected;

  /// No description provided for @photoIdentifyingPlant.
  ///
  /// In ca, this message translates to:
  /// **'Identificant planta...'**
  String get photoIdentifyingPlant;

  /// No description provided for @photoCenterPlantInFrame.
  ///
  /// In ca, this message translates to:
  /// **'Centra la planta dins el marc'**
  String get photoCenterPlantInFrame;

  /// No description provided for @plantResultTitle.
  ///
  /// In ca, this message translates to:
  /// **'Planta identificada'**
  String get plantResultTitle;

  /// No description provided for @plantResultScientificName.
  ///
  /// In ca, this message translates to:
  /// **'Nom científic'**
  String get plantResultScientificName;

  /// No description provided for @plantResultFamily.
  ///
  /// In ca, this message translates to:
  /// **'Família'**
  String get plantResultFamily;

  /// No description provided for @plantResultConfidence.
  ///
  /// In ca, this message translates to:
  /// **'Confiança'**
  String get plantResultConfidence;

  /// No description provided for @plantResultTakeAnotherPhoto.
  ///
  /// In ca, this message translates to:
  /// **'Fer una altra foto'**
  String get plantResultTakeAnotherPhoto;

  /// No description provided for @profileStatsTitle.
  ///
  /// In ca, this message translates to:
  /// **'Estadístiques'**
  String get profileStatsTitle;

  /// No description provided for @profileDefaultUser.
  ///
  /// In ca, this message translates to:
  /// **'Usuari'**
  String get profileDefaultUser;

  /// No description provided for @profileCityNotDefined.
  ///
  /// In ca, this message translates to:
  /// **'Ciutat no definida'**
  String get profileCityNotDefined;

  /// No description provided for @profileCoins.
  ///
  /// In ca, this message translates to:
  /// **'Monedes'**
  String get profileCoins;

  /// No description provided for @profileDiscovered.
  ///
  /// In ca, this message translates to:
  /// **'Descobertes'**
  String get profileDiscovered;

  /// No description provided for @profileUserLabel.
  ///
  /// In ca, this message translates to:
  /// **'Usuari'**
  String get profileUserLabel;

  /// No description provided for @profileEmailLabel.
  ///
  /// In ca, this message translates to:
  /// **'Email'**
  String get profileEmailLabel;

  /// No description provided for @profileCityLabel.
  ///
  /// In ca, this message translates to:
  /// **'Ciutat'**
  String get profileCityLabel;

  /// No description provided for @profileLanguageLabel.
  ///
  /// In ca, this message translates to:
  /// **'Idioma'**
  String get profileLanguageLabel;

  /// No description provided for @profileEditButton.
  ///
  /// In ca, this message translates to:
  /// **'Modificar perfil'**
  String get profileEditButton;

  /// No description provided for @profilePlants.
  ///
  /// In ca, this message translates to:
  /// **'Plantes'**
  String get profilePlants;

  /// No description provided for @profileLogout.
  ///
  /// In ca, this message translates to:
  /// **'Tancar sessió'**
  String get profileLogout;

  /// No description provided for @profileDeleteAccountTitle.
  ///
  /// In ca, this message translates to:
  /// **'Eliminar compte'**
  String get profileDeleteAccountTitle;

  /// No description provided for @profileDeleteAccountMessage.
  ///
  /// In ca, this message translates to:
  /// **'Estàs segur que vols eliminar el teu compte? Aquesta acció és permanent i es perdran totes les teves monedes i plantes descobertes.'**
  String get profileDeleteAccountMessage;

  /// No description provided for @profileDeleteAccountError.
  ///
  /// In ca, this message translates to:
  /// **'Error eliminant el compte'**
  String get profileDeleteAccountError;

  /// No description provided for @profileDeleteAccountConfirm.
  ///
  /// In ca, this message translates to:
  /// **'Sí, eliminar'**
  String get profileDeleteAccountConfirm;

  /// No description provided for @createAccountTitle.
  ///
  /// In ca, this message translates to:
  /// **'Crear compte'**
  String get createAccountTitle;

  /// No description provided for @createAccountWelcome.
  ///
  /// In ca, this message translates to:
  /// **'Benvingut a Meteo Garden'**
  String get createAccountWelcome;

  /// No description provided for @createAccountSubtitle.
  ///
  /// In ca, this message translates to:
  /// **'Omple les teves dades per començar'**
  String get createAccountSubtitle;

  /// No description provided for @createAccountEmailLabel.
  ///
  /// In ca, this message translates to:
  /// **'Correu electrònic'**
  String get createAccountEmailLabel;

  /// No description provided for @createAccountGardenNameLabel.
  ///
  /// In ca, this message translates to:
  /// **'Nom del teu jardí'**
  String get createAccountGardenNameLabel;

  /// No description provided for @createAccountSuccess.
  ///
  /// In ca, this message translates to:
  /// **'Compte creat correctament!'**
  String get createAccountSuccess;

  /// No description provided for @createAccountError.
  ///
  /// In ca, this message translates to:
  /// **'Error creant el compte'**
  String get createAccountError;

  /// No description provided for @completeProfileTitle.
  ///
  /// In ca, this message translates to:
  /// **'Completar perfil'**
  String get completeProfileTitle;

  /// No description provided for @completeProfileHeading.
  ///
  /// In ca, this message translates to:
  /// **'Ja quasi ho tenim!'**
  String get completeProfileHeading;

  /// No description provided for @completeProfileSubtitle.
  ///
  /// In ca, this message translates to:
  /// **'Completa aquestes dades per finalitzar el registre amb Google'**
  String get completeProfileSubtitle;

  /// No description provided for @completeProfilePasswordOptional.
  ///
  /// In ca, this message translates to:
  /// **'Contrasenya (Opcional)'**
  String get completeProfilePasswordOptional;

  /// No description provided for @completeProfileSuccess.
  ///
  /// In ca, this message translates to:
  /// **'Compte completat correctament!'**
  String get completeProfileSuccess;

  /// No description provided for @completeProfileError.
  ///
  /// In ca, this message translates to:
  /// **'Error completant perfil'**
  String get completeProfileError;

  /// No description provided for @profileEditTitle.
  ///
  /// In ca, this message translates to:
  /// **'Modificar perfil'**
  String get profileEditTitle;

  /// No description provided for @profileEditUserDataTitle.
  ///
  /// In ca, this message translates to:
  /// **'Dades d\'usuari'**
  String get profileEditUserDataTitle;

  /// No description provided for @profileEditUpdated.
  ///
  /// In ca, this message translates to:
  /// **'Perfil actualitzat'**
  String get profileEditUpdated;

  /// No description provided for @profileEditUpdateError.
  ///
  /// In ca, this message translates to:
  /// **'Error actualitzant el perfil'**
  String get profileEditUpdateError;

  /// No description provided for @languageCatalan.
  ///
  /// In ca, this message translates to:
  /// **'Català'**
  String get languageCatalan;

  /// No description provided for @languageSpanish.
  ///
  /// In ca, this message translates to:
  /// **'Castellà'**
  String get languageSpanish;

  /// No description provided for @languageEnglish.
  ///
  /// In ca, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @inventoryTitle.
  ///
  /// In ca, this message translates to:
  /// **'El teu inventari'**
  String get inventoryTitle;

  /// No description provided for @inventorySearchHint.
  ///
  /// In ca, this message translates to:
  /// **'Cerca una llavor o poció...'**
  String get inventorySearchHint;

  /// No description provided for @inventorySeedsTab.
  ///
  /// In ca, this message translates to:
  /// **'Llavors'**
  String get inventorySeedsTab;

  /// No description provided for @inventoryPotionsTab.
  ///
  /// In ca, this message translates to:
  /// **'Pocions'**
  String get inventoryPotionsTab;

  /// No description provided for @inventoryNoSeeds.
  ///
  /// In ca, this message translates to:
  /// **'No hi ha llavors disponibles'**
  String get inventoryNoSeeds;

  /// No description provided for @inventoryNoPotions.
  ///
  /// In ca, this message translates to:
  /// **'No hi ha pocions disponibles'**
  String get inventoryNoPotions;

  /// No description provided for @inventoryAvailableItems.
  ///
  /// In ca, this message translates to:
  /// **'{count} elements disponibles'**
  String inventoryAvailableItems(Object count);

  /// No description provided for @inventoryQuantity.
  ///
  /// In ca, this message translates to:
  /// **'Quantitat: {amount}'**
  String inventoryQuantity(Object amount);

  /// No description provided for @gardenLoadingSeedsError.
  ///
  /// In ca, this message translates to:
  /// **'Error carregant llavors'**
  String get gardenLoadingSeedsError;

  /// No description provided for @gardenLoadingWeather.
  ///
  /// In ca, this message translates to:
  /// **'Carregant meteo...'**
  String get gardenLoadingWeather;

  /// No description provided for @gardenWaitMoment.
  ///
  /// In ca, this message translates to:
  /// **'Espera un moment'**
  String get gardenWaitMoment;

  /// No description provided for @gardenWeatherLoadError.
  ///
  /// In ca, this message translates to:
  /// **'No s\'ha pogut carregar la meteo'**
  String get gardenWeatherLoadError;

  /// No description provided for @gardenTapToRetry.
  ///
  /// In ca, this message translates to:
  /// **'Toca per tornar-ho a provar'**
  String get gardenTapToRetry;

  /// No description provided for @gardenLoadingPotsError.
  ///
  /// In ca, this message translates to:
  /// **'Error carregant els tests:'**
  String get gardenLoadingPotsError;

  /// No description provided for @gardenNoPotsAvailable.
  ///
  /// In ca, this message translates to:
  /// **'No hi ha tests disponibles'**
  String get gardenNoPotsAvailable;

  /// No description provided for @gardenWeatherSummary.
  ///
  /// In ca, this message translates to:
  /// **'Temperatura: {temp}°C | Precipitació: {precipitation}'**
  String gardenWeatherSummary(Object temp, Object precipitation);

  /// No description provided for @gardenWindSummary.
  ///
  /// In ca, this message translates to:
  /// **'Vent: {wind} m/s'**
  String gardenWindSummary(Object wind);

  /// No description provided for @waterlabel.
  ///
  /// In ca, this message translates to:
  /// **'Nivell d\'Aigua'**
  String get waterlabel;

  /// No description provided for @salut.
  ///
  /// In ca, this message translates to:
  /// **'Salut'**
  String get salut;

  /// No description provided for @lastReg.
  ///
  /// In ca, this message translates to:
  /// **'Últim reg: '**
  String get lastReg;

  /// No description provided for @regar.
  ///
  /// In ca, this message translates to:
  /// **'Regar planta'**
  String get regar;

  /// No description provided for @recolectPlant.
  ///
  /// In ca, this message translates to:
  /// **'Recollir planta'**
  String get recolectPlant;

  /// No description provided for @aplyPotion.
  ///
  /// In ca, this message translates to:
  /// **'Aplicar poció'**
  String get aplyPotion;

  /// No description provided for @selectPotion.
  ///
  /// In ca, this message translates to:
  /// **'Selecciona una poció pel test'**
  String get selectPotion;

  /// No description provided for @errorPotions.
  ///
  /// In ca, this message translates to:
  /// **'Error carregant potions'**
  String get errorPotions;

  /// No description provided for @readyPotion.
  ///
  /// In ca, this message translates to:
  /// **'Poció disponible per aplicar'**
  String get readyPotion;

  /// No description provided for @aplyingPotion.
  ///
  /// In ca, this message translates to:
  /// **'Aplicant...'**
  String get aplyingPotion;

  /// No description provided for @noPotions.
  ///
  /// In ca, this message translates to:
  /// **'No tens potions disponibles'**
  String get noPotions;

  /// No description provided for @extraPotions.
  ///
  /// In ca, this message translates to:
  /// **'Quan n\'aconsegueixis, les podràs aplicar aquí.'**
  String get extraPotions;

  /// No description provided for @testbuit.
  ///
  /// In ca, this message translates to:
  /// **'Test Buit'**
  String get testbuit;

  /// No description provided for @selectionLlavor.
  ///
  /// In ca, this message translates to:
  /// **'Selecciona una llavor pel test'**
  String get selectionLlavor;

  /// No description provided for @llavorDisp.
  ///
  /// In ca, this message translates to:
  /// **'Llavor disponible per plantar'**
  String get llavorDisp;

  /// No description provided for @plant.
  ///
  /// In ca, this message translates to:
  /// **'Plantar'**
  String get plant;

  /// No description provided for @planting.
  ///
  /// In ca, this message translates to:
  /// **'Plantant...'**
  String get planting;

  /// No description provided for @noLlavor.
  ///
  /// In ca, this message translates to:
  /// **'No tens llavors disponibles'**
  String get noLlavor;

  /// No description provided for @extraLlavor.
  ///
  /// In ca, this message translates to:
  /// **'Quan n\'aconsegueixis, les podràs plantar aquí.'**
  String get extraLlavor;

  /// No description provided for @confirmDeletePlant.
  ///
  /// In ca, this message translates to:
  /// **'Segur que vols eliminar {plantName}?\nAquesta acció no es pot desfer.'**
  String confirmDeletePlant(Object plantName);

  /// No description provided for @thisPlant.
  ///
  /// In ca, this message translates to:
  /// **'aquesta planta'**
  String get thisPlant;

  /// No description provided for @deletePlant.
  ///
  /// In ca, this message translates to:
  /// **'Eliminar planta'**
  String get deletePlant;

  /// No description provided for @finalitza.
  ///
  /// In ca, this message translates to:
  /// **'Finalitza el'**
  String get finalitza;

  /// No description provided for @avatarLoadError.
  ///
  /// In ca, this message translates to:
  /// **'Error carregant l\'avatar'**
  String get avatarLoadError;

  /// No description provided for @createYourAvatar.
  ///
  /// In ca, this message translates to:
  /// **'Crea el teu avatar'**
  String get createYourAvatar;

  /// No description provided for @editAvatar.
  ///
  /// In ca, this message translates to:
  /// **'Edita el teu avatar'**
  String get editAvatar;

  /// No description provided for @errorLoadingOptions.
  ///
  /// In ca, this message translates to:
  /// **'Error carregant opcions'**
  String get errorLoadingOptions;

  /// No description provided for @errorConnectionOptions.
  ///
  /// In ca, this message translates to:
  /// **'Error de connexió carregant les opcions.'**
  String get errorConnectionOptions;

  /// No description provided for @errorConnectionAvatar.
  ///
  /// In ca, this message translates to:
  /// **'Error de connexió carregant l\'avatar.'**
  String get errorConnectionAvatar;

  /// No description provided for @errorSavingAvatar.
  ///
  /// In ca, this message translates to:
  /// **'Error guardant l\'avatar'**
  String get errorSavingAvatar;

  /// No description provided for @errorConnectionSaving.
  ///
  /// In ca, this message translates to:
  /// **'Error de connexió guardant l\'avatar.'**
  String get errorConnectionSaving;

  /// No description provided for @noOptionsAvailable.
  ///
  /// In ca, this message translates to:
  /// **'No hi ha opcions disponibles'**
  String get noOptionsAvailable;

  /// No description provided for @continueButton.
  ///
  /// In ca, this message translates to:
  /// **'Continuar'**
  String get continueButton;

  /// No description provided for @saveChangesButton.
  ///
  /// In ca, this message translates to:
  /// **'Guardar canvis'**
  String get saveChangesButton;

  /// No description provided for @categoryBody.
  ///
  /// In ca, this message translates to:
  /// **'Cos'**
  String get categoryBody;

  /// No description provided for @categoryEyes.
  ///
  /// In ca, this message translates to:
  /// **'Ulls'**
  String get categoryEyes;

  /// No description provided for @categoryExpression.
  ///
  /// In ca, this message translates to:
  /// **'Expressió'**
  String get categoryExpression;

  /// No description provided for @categoryHair.
  ///
  /// In ca, this message translates to:
  /// **'Cabell'**
  String get categoryHair;

  /// No description provided for @categoryFacialHair.
  ///
  /// In ca, this message translates to:
  /// **'Barba'**
  String get categoryFacialHair;

  /// No description provided for @categoryClothing.
  ///
  /// In ca, this message translates to:
  /// **'Roba'**
  String get categoryClothing;

  /// No description provided for @categoryAccessories.
  ///
  /// In ca, this message translates to:
  /// **'Accessoris'**
  String get categoryAccessories;

  /// No description provided for @errorMessageSession.
  ///
  /// In ca, this message translates to:
  /// **'Error iniciant sessió'**
  String get errorMessageSession;

  /// No description provided for @connectionError.
  ///
  /// In ca, this message translates to:
  /// **'Error de connexió'**
  String get connectionError;

  /// No description provided for @allCities.
  ///
  /// In ca, this message translates to:
  /// **'Totes les ciutats'**
  String get allCities;

  /// No description provided for @noEventsToday.
  ///
  /// In ca, this message translates to:
  /// **'No hi ha events aquest dia'**
  String get noEventsToday;

  /// No description provided for @phaseSeed.
  ///
  /// In ca, this message translates to:
  /// **'Llavor'**
  String get phaseSeed;

  /// No description provided for @phaseGermination.
  ///
  /// In ca, this message translates to:
  /// **'Germinació'**
  String get phaseGermination;

  /// No description provided for @phaseGrowth.
  ///
  /// In ca, this message translates to:
  /// **'Creixement'**
  String get phaseGrowth;

  /// No description provided for @phaseMature.
  ///
  /// In ca, this message translates to:
  /// **'Madura'**
  String get phaseMature;

  /// No description provided for @phaseFlowering.
  ///
  /// In ca, this message translates to:
  /// **'Floració'**
  String get phaseFlowering;

  /// No description provided for @phaseDead.
  ///
  /// In ca, this message translates to:
  /// **'Morta'**
  String get phaseDead;

  /// No description provided for @avatarLoadErrorPersist.
  ///
  /// In ca, this message translates to:
  /// **'Error carregant l\'avatar'**
  String get avatarLoadErrorPersist;

  /// No description provided for @filterByCity.
  ///
  /// In ca, this message translates to:
  /// **'Filtra per ciutat'**
  String get filterByCity;

  /// No description provided for @writeCity.
  ///
  /// In ca, this message translates to:
  /// **'Escriu una ciutat...'**
  String get writeCity;

  /// No description provided for @commonApply.
  ///
  /// In ca, this message translates to:
  /// **'Aplicar'**
  String get commonApply;

  /// No description provided for @plantWateredSuccess.
  ///
  /// In ca, this message translates to:
  /// **'Planta regada correctament'**
  String get plantWateredSuccess;

  /// No description provided for @plantCollectedSuccess.
  ///
  /// In ca, this message translates to:
  /// **'Planta recol·lectada correctament'**
  String get plantCollectedSuccess;

  /// No description provided for @plantDeletedSuccess.
  ///
  /// In ca, this message translates to:
  /// **'Planta eliminada correctament'**
  String get plantDeletedSuccess;

  /// No description provided for @plantActionError.
  ///
  /// In ca, this message translates to:
  /// **'No s\'ha pogut completar l\'acció'**
  String get plantActionError;

  /// No description provided for @plantLoadingSeedsError.
  ///
  /// In ca, this message translates to:
  /// **'No s\'han pogut carregar les llavors'**
  String get plantLoadingSeedsError;

  /// No description provided for @weatherDetailsTitle.
  ///
  /// In ca, this message translates to:
  /// **'Detalls del temps'**
  String get weatherDetailsTitle;

  /// No description provided for @weatherStationLabel.
  ///
  /// In ca, this message translates to:
  /// **'Estació Meteorològica'**
  String get weatherStationLabel;

  /// No description provided for @temperatureLabel.
  ///
  /// In ca, this message translates to:
  /// **'Temperatura'**
  String get temperatureLabel;

  /// No description provided for @humidityLabel.
  ///
  /// In ca, this message translates to:
  /// **'Humitat'**
  String get humidityLabel;

  /// No description provided for @windLabel.
  ///
  /// In ca, this message translates to:
  /// **'Vent'**
  String get windLabel;

  /// No description provided for @precipitationLabel.
  ///
  /// In ca, this message translates to:
  /// **'Precipitació'**
  String get precipitationLabel;

  /// No description provided for @solarIrradianceLabel.
  ///
  /// In ca, this message translates to:
  /// **'Irradiació solar'**
  String get solarIrradianceLabel;

  /// No description provided for @missionsTitle.
  ///
  /// In ca, this message translates to:
  /// **'Missions'**
  String get missionsTitle;

  /// No description provided for @missionsSubtitle.
  ///
  /// In ca, this message translates to:
  /// **'Completa reptes i guanya monedes'**
  String get missionsSubtitle;

  /// No description provided for @missionsCompleted.
  ///
  /// In ca, this message translates to:
  /// **'Completades'**
  String get missionsCompleted;

  /// No description provided for @missionsTagCompleted.
  ///
  /// In ca, this message translates to:
  /// **'Completada'**
  String get missionsTagCompleted;

  /// No description provided for @missionsTagInProgress.
  ///
  /// In ca, this message translates to:
  /// **'En progrés'**
  String get missionsTagInProgress;

  /// No description provided for @missionsEmpty.
  ///
  /// In ca, this message translates to:
  /// **'No hi ha missions disponibles'**
  String get missionsEmpty;

  /// No description provided for @missionsClaimSuccess.
  ///
  /// In ca, this message translates to:
  /// **'Recompensa reclamada!'**
  String get missionsClaimSuccess;

  /// No description provided for @missionsErrorAlreadyClaimed.
  ///
  /// In ca, this message translates to:
  /// **'Aquesta missió ja ha estat reclamada'**
  String get missionsErrorAlreadyClaimed;

  /// No description provided for @missionsErrorInProgress.
  ///
  /// In ca, this message translates to:
  /// **'La missió encara no està completada'**
  String get missionsErrorInProgress;

  /// No description provided for @missionsErrorNotFound.
  ///
  /// In ca, this message translates to:
  /// **'Missió no trobada'**
  String get missionsErrorNotFound;

  /// No description provided for @missionsErrorGeneric.
  ///
  /// In ca, this message translates to:
  /// **'No s\'ha pogut reclamar la recompensa'**
  String get missionsErrorGeneric;

  /// No description provided for @missionsClaim.
  ///
  /// In ca, this message translates to:
  /// **'Reclamar 🎁'**
  String get missionsClaim;

  /// No description provided for @missionsActiveSectionTitle.
  ///
  /// In ca, this message translates to:
  /// **'Missions actives'**
  String get missionsActiveSectionTitle;

  /// No description provided for @missionsClaimedSectionTitle.
  ///
  /// In ca, this message translates to:
  /// **'Ja reclamades'**
  String get missionsClaimedSectionTitle;

  /// No description provided for @missionsTagClaimed.
  ///
  /// In ca, this message translates to:
  /// **'Reclamada'**
  String get missionsTagClaimed;

  /// No description provided for @missionsInProgress.
  ///
  /// In ca, this message translates to:
  /// **'En curs'**
  String get missionsInProgress;

  /// No description provided for @missionsRewardCoins.
  ///
  /// In ca, this message translates to:
  /// **'monedes'**
  String get missionsRewardCoins;

  /// No description provided for @friends.
  ///
  /// In ca, this message translates to:
  /// **'Amics'**
  String get friends;

  /// No description provided for @sent.
  ///
  /// In ca, this message translates to:
  /// **'Enviades'**
  String get sent;

  /// No description provided for @received.
  ///
  /// In ca, this message translates to:
  /// **'Rebudes'**
  String get received;

  /// No description provided for @sendFriendRequestTooltip.
  ///
  /// In ca, this message translates to:
  /// **'Enviar sol·licitud d\'amistat'**
  String get sendFriendRequestTooltip;

  /// No description provided for @friendsCount.
  ///
  /// In ca, this message translates to:
  /// **'{count, plural, =1{1 amic} other{{count} amics}}'**
  String friendsCount(int count);

  /// No description provided for @friendsCountWithRequests.
  ///
  /// In ca, this message translates to:
  /// **'{friends, plural, =1{1 amic} other{{friends} amics}} · {requests, plural, =1{1 sol·licitud} other{{requests} sol·licituds}}'**
  String friendsCountWithRequests(int friends, int requests);

  /// No description provided for @noFriendsYet.
  ///
  /// In ca, this message translates to:
  /// **'Encara no tens amics.\nAfegeix-ne amb el botó superior!'**
  String get noFriendsYet;

  /// No description provided for @noSentRequests.
  ///
  /// In ca, this message translates to:
  /// **'No tens cap sol·licitud enviada pendent.'**
  String get noSentRequests;

  /// No description provided for @noReceivedRequests.
  ///
  /// In ca, this message translates to:
  /// **'No tens cap sol·licitud d\'amistat pendent.'**
  String get noReceivedRequests;

  /// No description provided for @cancel.
  ///
  /// In ca, this message translates to:
  /// **'Cancel·lar'**
  String get cancel;

  /// No description provided for @accept.
  ///
  /// In ca, this message translates to:
  /// **'Acceptar'**
  String get accept;

  /// No description provided for @reject.
  ///
  /// In ca, this message translates to:
  /// **'Rebutjar'**
  String get reject;

  /// No description provided for @addFriend.
  ///
  /// In ca, this message translates to:
  /// **'Afegir amic'**
  String get addFriend;

  /// No description provided for @addFriendSubtitle.
  ///
  /// In ca, this message translates to:
  /// **'Busca un usuari i envia-li una sol·licitud.'**
  String get addFriendSubtitle;

  /// No description provided for @usernameHint.
  ///
  /// In ca, this message translates to:
  /// **'Nom d\'usuari...'**
  String get usernameHint;

  /// No description provided for @visitGarden.
  ///
  /// In ca, this message translates to:
  /// **'Visita el seu jardí'**
  String get visitGarden;

  /// No description provided for @sendRequest.
  ///
  /// In ca, this message translates to:
  /// **'Enviar sol·licitud'**
  String get sendRequest;

  /// No description provided for @tryAgain.
  ///
  /// In ca, this message translates to:
  /// **'Tornar a intentar'**
  String get tryAgain;

  /// No description provided for @gardenLoadError.
  ///
  /// In ca, this message translates to:
  /// **'No s\'ha pogut carregar el jardí.'**
  String get gardenLoadError;

  /// No description provided for @emptyFriendGarden.
  ///
  /// In ca, this message translates to:
  /// **'Aquest jardí no té testos.'**
  String get emptyFriendGarden;

  /// No description provided for @likeGarden.
  ///
  /// In ca, this message translates to:
  /// **'Fer m\'agrada'**
  String get likeGarden;

  /// No description provided for @likedGarden.
  ///
  /// In ca, this message translates to:
  /// **'M\'agrada fet'**
  String get likedGarden;

  /// No description provided for @close.
  ///
  /// In ca, this message translates to:
  /// **'Tancar'**
  String get close;

  /// No description provided for @friendOptions.
  ///
  /// In ca, this message translates to:
  /// **'Opcions de l\'amic'**
  String get friendOptions;

  /// No description provided for @deleteFriend.
  ///
  /// In ca, this message translates to:
  /// **'Eliminar amic'**
  String get deleteFriend;

  /// No description provided for @deleteFriendTitle.
  ///
  /// In ca, this message translates to:
  /// **'Eliminar amic'**
  String get deleteFriendTitle;

  /// No description provided for @deleteFriendMessage.
  ///
  /// In ca, this message translates to:
  /// **'Segur que vols eliminar @{username} de la teva llista d\'amics?'**
  String deleteFriendMessage(String username);

  /// No description provided for @delete.
  ///
  /// In ca, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @friendRequestSentSuccessfully.
  ///
  /// In ca, this message translates to:
  /// **'Sol·licitud enviada correctament'**
  String get friendRequestSentSuccessfully;

  /// No description provided for @loginEmptyFields.
  ///
  /// In ca, this message translates to:
  /// **'Introdueix el nom d\'usuari i la contrasenya.'**
  String get loginEmptyFields;

  /// No description provided for @loginInvalidCredentials.
  ///
  /// In ca, this message translates to:
  /// **'Nom d\'usuari o contrasenya incorrectes.'**
  String get loginInvalidCredentials;

  /// No description provided for @loginServerError.
  ///
  /// In ca, this message translates to:
  /// **'No s\'ha pogut iniciar sessió. Torna-ho a provar més tard.'**
  String get loginServerError;

  /// No description provided for @loginConnectionError.
  ///
  /// In ca, this message translates to:
  /// **'No s\'ha pogut connectar amb el servidor.'**
  String get loginConnectionError;

  /// No description provided for @calendarAllCategories.
  ///
  /// In ca, this message translates to:
  /// **'Totes les categories'**
  String get calendarAllCategories;

  /// No description provided for @calendarFilters.
  ///
  /// In ca, this message translates to:
  /// **'Filtres'**
  String get calendarFilters;

  /// No description provided for @calendarCategory.
  ///
  /// In ca, this message translates to:
  /// **'Categoria'**
  String get calendarCategory;

  /// No description provided for @calendarAll.
  ///
  /// In ca, this message translates to:
  /// **'Totes'**
  String get calendarAll;

  /// No description provided for @calendarClear.
  ///
  /// In ca, this message translates to:
  /// **'Netejar'**
  String get calendarClear;

  /// No description provided for @calendarDayTitle.
  ///
  /// In ca, this message translates to:
  /// **'Dia {day} — {month}'**
  String calendarDayTitle(int day, String month);

  /// No description provided for @calendarFiltersTooltip.
  ///
  /// In ca, this message translates to:
  /// **'Filtres'**
  String get calendarFiltersTooltip;

  /// No description provided for @culturalEvents.
  ///
  /// In ca, this message translates to:
  /// **'Events culturals'**
  String get culturalEvents;
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
