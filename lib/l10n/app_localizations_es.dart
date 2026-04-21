// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'MeteoGarden';

  @override
  String get loginWelcomeTitle => 'Benvinguda a MeteoGarden';

  @override
  String get loginWelcomeSubtitle =>
      'Inicia sessió per continuar cuidant el teu jardí.';

  @override
  String get loginUsernameLabel => 'Nom d\'usuari';

  @override
  String get loginUsernameHint => 'Introdueix el teu nom d\'usuari';

  @override
  String get loginPasswordLabel => 'Contrasenya';

  @override
  String get loginPasswordHint => 'Introdueix la teva contrasenya';

  @override
  String get loginButton => 'Iniciar sessió';

  @override
  String get loginContinueWith => 'o continuar amb';

  @override
  String get loginNoAccount => 'No tens compte?';

  @override
  String get loginCreateAccount => 'Crear compte';

  @override
  String get loginError => 'Error de login';

  @override
  String get loginGoogleError => 'Error login Google';

  @override
  String get profileLoadError => 'No s\'ha pogut carregar el perfil';

  @override
  String get navGarden => 'Jardí';

  @override
  String get navFriends => 'Amics';

  @override
  String get navCamera => 'Càmera';

  @override
  String get navMissions => 'Missions';

  @override
  String get navProfile => 'Perfil';

  @override
  String get commonLanguage => 'Idioma';

  @override
  String get commonCity => 'Ciutat';

  @override
  String get commonContinue => 'Continuar';

  @override
  String get albumTitle => 'El meu àlbum de plantes';

  @override
  String get albumDiscoveredPlants => 'Plantes descobertes';

  @override
  String get albumLoadingEncyclopedia => 'Consultant enciclopèdia...';

  @override
  String albumDetailsLoadError(String error) {
    return 'Error carregant detalls: $error';
  }

  @override
  String get albumUnknownPlant => 'Desconeguda';

  @override
  String get albumNoDescription => 'No hi ha descripció disponible.';

  @override
  String get albumFamilyLabel => 'Família';

  @override
  String get albumBlooms => 'Floreix';

  @override
  String get albumDoesNotBloom => 'No floreix';

  @override
  String get albumDescriptionTitle => 'Descripció';

  @override
  String get commonClose => 'Tancar';

  @override
  String get albumEmptyState =>
      'Encara no has descobert cap planta 🌱\nContinua explorant!';

  @override
  String get albumPlantInfoLoadError =>
      'Error carregant la informació de la planta';

  @override
  String get commonBack => 'Tornar';

  @override
  String get shopTitle => 'Botiga';

  @override
  String get shopSeedsTab => 'Llavors 🌱';

  @override
  String get shopOtherTab => 'Altres 🛒';

  @override
  String get shopLoadError => 'No s\'han pogut carregar els productes.';

  @override
  String get shopConnectionError => 'Error de connexió o processant les dades.';

  @override
  String get shopPurchaseProcessingError => 'Error en processar la compra.';

  @override
  String get shopPurchaseSuccess => 'Compra realitzada amb èxit! 🌱';

  @override
  String get shopDescriptionTitle => 'Descripció';

  @override
  String get shopTotalPrice => 'Preu total:';

  @override
  String get shopBuyButton => 'Comprar';

  @override
  String get shopNoItemsAvailable =>
      'No hi ha articles disponibles ara mateix.';

  @override
  String get calendarRetry => 'Reintentar';

  @override
  String get calendarUpcomingEvents => 'Propers esdeveniments';

  @override
  String get calendarNoEventsThisMonth => 'No hi ha esdeveniments aquest mes';

  @override
  String get calendarClearFilters => 'Eliminar filtres';

  @override
  String get calendarNoEventsThisDay => 'Sense esdeveniments aquest dia';

  @override
  String get calendarFiltersTitle => 'Filtres';

  @override
  String get calendarClearAll => 'Netejar tot';

  @override
  String get calendarSearchTextLabel => 'Cerca per text';

  @override
  String get calendarSearchTextHint => 'Nom, descripció...';

  @override
  String get calendarCityLabel => 'Ciutat';

  @override
  String get calendarCityHint => 'Barcelona, Girona...';

  @override
  String get calendarCountyLabel => 'Comarca';

  @override
  String get calendarCountyHint => 'Osona, Maresme...';

  @override
  String get calendarCategoryLabel => 'Categoria';

  @override
  String get calendarCategoryHint => 'Mercat, Concert, Ruta...';

  @override
  String get calendarMaxDistanceLabel => 'Distància màxima';

  @override
  String get calendarMaxPriceLabel => 'Preu màxim';

  @override
  String get calendarApplyFilters => 'Aplicar filtres';

  @override
  String get calendarFree => 'Gratis';

  @override
  String get calendarFreeAccent => 'Gratuït';

  @override
  String get calendarBuyTickets => 'Comprar entrades';

  @override
  String get calendarEventSingular => 'esdeveniment';

  @override
  String get calendarEventPlural => 'esdeveniments';

  @override
  String calendarEventsCount(Object count) {
    return '$count esdeveniments';
  }

  @override
  String calendarSelectedDaySummary(
    Object day,
    Object month,
    Object count,
    Object eventWord,
  ) {
    return '$day $month · $count $eventWord';
  }

  @override
  String calendarMaxDistanceChip(Object km) {
    return '≤$km km';
  }

  @override
  String calendarMaxPriceChip(Object price) {
    return '≤$price€';
  }

  @override
  String calendarSearchChip(Object query) {
    return '\"$query\"';
  }

  @override
  String calendarDistanceKm(Object km) {
    return '$km km';
  }

  @override
  String calendarPriceEuros(Object price) {
    return '$price €';
  }

  @override
  String calendarPriceCompact(Object price) {
    return '$price€';
  }

  @override
  String get weekdayMon => 'Dl';

  @override
  String get weekdayTue => 'Dt';

  @override
  String get weekdayWed => 'Dc';

  @override
  String get weekdayThu => 'Dj';

  @override
  String get weekdayFri => 'Dv';

  @override
  String get weekdaySat => 'Ds';

  @override
  String get weekdaySun => 'Dg';

  @override
  String get monthJanuary => 'Gener';

  @override
  String get monthFebruary => 'Febrer';

  @override
  String get monthMarch => 'Març';

  @override
  String get monthApril => 'Abril';

  @override
  String get monthMay => 'Maig';

  @override
  String get monthJune => 'Juny';

  @override
  String get monthJuly => 'Juliol';

  @override
  String get monthAugust => 'Agost';

  @override
  String get monthSeptember => 'Setembre';

  @override
  String get monthOctober => 'Octubre';

  @override
  String get monthNovember => 'Novembre';

  @override
  String get monthDecember => 'Desembre';
}
