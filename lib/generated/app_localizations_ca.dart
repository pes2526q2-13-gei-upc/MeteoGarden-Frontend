// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Catalan Valencian (`ca`).
class AppLocalizationsCa extends AppLocalizations {
  AppLocalizationsCa([String locale = 'ca']) : super(locale);

  @override
  String get appTitle => 'MeteoGarden';

  @override
  String get commonBack => 'Tornar';

  @override
  String get commonCancel => 'Cancel·lar';

  @override
  String get commonCity => 'Ciutat';

  @override
  String get commonClose => 'Tancar';

  @override
  String get commonContinue => 'Continuar';

  @override
  String get commonDescription => 'Descripció';

  @override
  String get commonLanguage => 'Idioma';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonSearch => 'Cerca';

  @override
  String get commonEliminar => 'Eliminar';

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
  String get albumEmptyState =>
      'Encara no has descobert cap planta 🌱\nContinua explorant!';

  @override
  String get albumPlantInfoLoadError =>
      'Error carregant la informació de la planta';

  @override
  String get albumNumber => 'plantes descobertes';

  @override
  String get shopTitle => 'Botiga';

  @override
  String get shopSeedsTab => 'Llavors';

  @override
  String get shopOtherTab => 'Altres';

  @override
  String get shopLoadError => 'No s\'han pogut carregar els productes.';

  @override
  String get shopConnectionError => 'Error de connexió o processant les dades.';

  @override
  String get shopPurchaseProcessingError => 'Error en processar la compra.';

  @override
  String get shopPurchaseSuccess => 'Compra realitzada amb èxit! 🌱';

  @override
  String get shopTotalPrice => 'Preu total:';

  @override
  String get shopBuyButton => 'Comprar';

  @override
  String get shopNoItemsAvailable =>
      'No hi ha articles disponibles ara mateix.';

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

  @override
  String get monthShortJanuary => 'gen';

  @override
  String get monthShortFebruary => 'feb';

  @override
  String get monthShortMarch => 'març';

  @override
  String get monthShortApril => 'abr';

  @override
  String get monthShortMay => 'maig';

  @override
  String get monthShortJune => 'juny';

  @override
  String get monthShortJuly => 'jul';

  @override
  String get monthShortAugust => 'ago';

  @override
  String get monthShortSeptember => 'set';

  @override
  String get monthShortOctober => 'oct';

  @override
  String get monthShortNovember => 'nov';

  @override
  String get monthShortDecember => 'des';

  @override
  String get photoNoCameraAvailable => 'No s’ha trobat cap càmera disponible.';

  @override
  String get photoCameraInitError => 'No s’ha pogut inicialitzar la càmera.';

  @override
  String get photoUnexpectedError => 'S’ha produït un error inesperat.';

  @override
  String get photoTakePlantPicture => 'Fotografia la planta';

  @override
  String get photoTreeMode => 'Fulla';

  @override
  String get photoFlowerMode => 'Flor';

  @override
  String get photoTreeModeSelected => 'Mode fulla seleccionat';

  @override
  String get photoFlowerModeSelected => 'Mode flor seleccionat';

  @override
  String get photoIdentifyingPlant => 'Identificant planta...';

  @override
  String get photoCenterPlantInFrame => 'Centra la planta dins el marc';

  @override
  String get plantResultTitle => 'Planta identificada';

  @override
  String get plantResultScientificName => 'Nom científic';

  @override
  String get plantResultFamily => 'Família';

  @override
  String get plantResultConfidence => 'Confiança';

  @override
  String get plantResultTakeAnotherPhoto => 'Fer una altra foto';

  @override
  String get profileStatsTitle => 'Estadístiques';

  @override
  String get profileDefaultUser => 'Usuari';

  @override
  String get profileCityNotDefined => 'Ciutat no definida';

  @override
  String get profileCoins => 'Monedes';

  @override
  String get profileDiscovered => 'Descobertes';

  @override
  String get profileUserLabel => 'Usuari';

  @override
  String get profileEmailLabel => 'Email';

  @override
  String get profileCityLabel => 'Ciutat';

  @override
  String get profileLanguageLabel => 'Idioma';

  @override
  String get profileEditButton => 'Modificar perfil';

  @override
  String get profilePlants => 'Plantes';

  @override
  String get profileLogout => 'Tancar sessió';

  @override
  String get profileDeleteAccountTitle => 'Eliminar compte';

  @override
  String get profileDeleteAccountMessage =>
      'Estàs segur que vols eliminar el teu compte? Aquesta acció és permanent i es perdran totes les teves monedes i plantes descobertes.';

  @override
  String get profileDeleteAccountError => 'Error eliminant el compte';

  @override
  String get profileDeleteAccountConfirm => 'Sí, eliminar';

  @override
  String get createAccountTitle => 'Crear compte';

  @override
  String get createAccountWelcome => 'Benvingut a Meteo Garden';

  @override
  String get createAccountSubtitle => 'Omple les teves dades per començar';

  @override
  String get createAccountEmailLabel => 'Correu electrònic';

  @override
  String get createAccountGardenNameLabel => 'Nom del teu jardí';

  @override
  String get createAccountSuccess => 'Compte creat correctament!';

  @override
  String get createAccountError => 'Error creant el compte';

  @override
  String get completeProfileTitle => 'Completar perfil';

  @override
  String get completeProfileHeading => 'Ja quasi ho tenim!';

  @override
  String get completeProfileSubtitle =>
      'Completa aquestes dades per finalitzar el registre amb Google';

  @override
  String get completeProfilePasswordOptional => 'Contrasenya (Opcional)';

  @override
  String get completeProfileSuccess => 'Compte completat correctament!';

  @override
  String get completeProfileError => 'Error completant perfil';

  @override
  String get profileEditTitle => 'Modificar perfil';

  @override
  String get profileEditUserDataTitle => 'Dades d\'usuari';

  @override
  String get profileEditUpdated => 'Perfil actualitzat';

  @override
  String get profileEditUpdateError => 'Error actualitzant el perfil';

  @override
  String get languageCatalan => 'Català';

  @override
  String get languageSpanish => 'Castellà';

  @override
  String get languageEnglish => 'English';

  @override
  String get inventoryTitle => 'El teu inventari';

  @override
  String get inventorySearchHint => 'Cerca una llavor o poció...';

  @override
  String get inventorySeedsTab => 'Llavors';

  @override
  String get inventoryPotionsTab => 'Pocions';

  @override
  String get inventoryNoSeeds => 'No hi ha llavors disponibles';

  @override
  String get inventoryNoPotions => 'No hi ha pocions disponibles';

  @override
  String inventoryAvailableItems(Object count) {
    return '$count elements disponibles';
  }

  @override
  String inventoryQuantity(Object amount) {
    return 'Quantitat: $amount';
  }

  @override
  String get gardenLoadingSeedsError => 'Error carregant llavors';

  @override
  String get gardenLoadingWeather => 'Carregant meteo...';

  @override
  String get gardenWaitMoment => 'Espera un moment';

  @override
  String get gardenWeatherLoadError => 'No s\'ha pogut carregar la meteo';

  @override
  String get gardenTapToRetry => 'Toca per tornar-ho a provar';

  @override
  String get gardenLoadingPotsError => 'Error carregant els tests:';

  @override
  String get gardenNoPotsAvailable => 'No hi ha tests disponibles';

  @override
  String gardenWeatherSummary(Object temp, Object precipitation) {
    return 'Temperatura: $temp°C | Precipitació: $precipitation';
  }

  @override
  String gardenWindSummary(Object wind) {
    return 'Vent: $wind m/s';
  }

  @override
  String get waterlabel => 'Nivell d\'Aigua';

  @override
  String get salut => 'Salut';

  @override
  String get lastReg => 'Últim reg: ';

  @override
  String get regar => 'Regar planta';

  @override
  String get recolectPlant => 'Recollir planta';

  @override
  String get aplyPotion => 'Aplicar poció';

  @override
  String get selectPotion => 'Selecciona una poció pel test';

  @override
  String get errorPotions => 'Error carregant potions';

  @override
  String get readyPotion => 'Poció disponible per aplicar';

  @override
  String get aplyingPotion => 'Aplicant...';

  @override
  String get noPotions => 'No tens potions disponibles';

  @override
  String get extraPotions => 'Quan n\'aconsegueixis, les podràs aplicar aquí.';

  @override
  String get testbuit => 'Test Buit';

  @override
  String get selectionLlavor => 'Selecciona una llavor pel test';

  @override
  String get llavorDisp => 'Llavor disponible per plantar';

  @override
  String get plant => 'Plantar';

  @override
  String get planting => 'Plantant...';

  @override
  String get noLlavor => 'No tens llavors disponibles';

  @override
  String get extraLlavor => 'Quan n\'aconsegueixis, les podràs plantar aquí.';

  @override
  String confirmDeletePlant(Object plantName) {
    return 'Segur que vols eliminar $plantName?\nAquesta acció no es pot desfer.';
  }

  @override
  String get thisPlant => 'aquesta planta';

  @override
  String get deletePlant => 'Eliminar planta';

  @override
  String get finalitza => 'Finalitza el';

  @override
  String get avatarLoadError => 'Error carregant l\'avatar';

  @override
  String get createYourAvatar => 'Crea el teu avatar';

  @override
  String get editAvatar => 'Edita el teu avatar';

  @override
  String get errorLoadingOptions => 'Error carregant opcions';

  @override
  String get errorConnectionOptions =>
      'Error de connexió carregant les opcions.';

  @override
  String get errorConnectionAvatar => 'Error de connexió carregant l\'avatar.';

  @override
  String get errorSavingAvatar => 'Error guardant l\'avatar';

  @override
  String get errorConnectionSaving => 'Error de connexió guardant l\'avatar.';

  @override
  String get noOptionsAvailable => 'No hi ha opcions disponibles';

  @override
  String get continueButton => 'Continuar';

  @override
  String get saveChangesButton => 'Guardar canvis';

  @override
  String get categoryBody => 'Cos';

  @override
  String get categoryEyes => 'Ulls';

  @override
  String get categoryExpression => 'Expressió';

  @override
  String get categoryHair => 'Cabell';

  @override
  String get categoryFacialHair => 'Barba';

  @override
  String get categoryClothing => 'Roba';

  @override
  String get categoryAccessories => 'Accessoris';

  @override
  String get errorMessageSession => 'Error iniciant sessió';

  @override
  String get connectionError => 'Error de connexió';

  @override
  String get allCities => 'Totes les ciutats';

  @override
  String get noEventsToday => 'No hi ha events aquest dia';

  @override
  String get phaseSeed => 'Llavor';

  @override
  String get phaseGermination => 'Germinació';

  @override
  String get phaseGrowth => 'Creixement';

  @override
  String get phaseMature => 'Madura';

  @override
  String get phaseFlowering => 'Floració';

  @override
  String get phaseDead => 'Morta';

  @override
  String get avatarLoadErrorPersist => 'Error carregant l\'avatar';

  @override
  String get filterByCity => 'Filtra per ciutat';

  @override
  String get writeCity => 'Escriu una ciutat...';

  @override
  String get commonApply => 'Aplicar';

  @override
  String get plantWateredSuccess => 'Planta regada correctament';

  @override
  String get plantCollectedSuccess => 'Planta recol·lectada correctament';

  @override
  String get plantDeletedSuccess => 'Planta eliminada correctament';

  @override
  String get plantActionError => 'No s\'ha pogut completar l\'acció';

  @override
  String get plantLoadingSeedsError => 'No s\'han pogut carregar les llavors';

  @override
  String get weatherDetailsTitle => 'Detalls del temps';

  @override
  String get weatherStationLabel => 'Estació Meteorològica';

  @override
  String get temperatureLabel => 'Temperatura';

  @override
  String get humidityLabel => 'Humitat';

  @override
  String get windLabel => 'Vent';

  @override
  String get precipitationLabel => 'Precipitació';

  @override
  String get solarIrradianceLabel => 'Irradiació solar';

  @override
  String get missionsTitle => 'Missions';

  @override
  String get missionsSubtitle => 'Completa reptes i guanya monedes';

  @override
  String get missionsCompleted => 'Completades';

  @override
  String get missionsTagCompleted => 'Completada';

  @override
  String get missionsTagInProgress => 'En progrés';

  @override
  String get missionsEmpty => 'No hi ha missions disponibles';

  @override
  String get missionsClaimSuccess => 'Recompensa reclamada!';

  @override
  String get missionsErrorAlreadyClaimed =>
      'Aquesta missió ja ha estat reclamada';

  @override
  String get missionsErrorInProgress => 'La missió encara no està completada';

  @override
  String get missionsErrorNotFound => 'Missió no trobada';

  @override
  String get missionsErrorGeneric => 'No s\'ha pogut reclamar la recompensa';

  @override
  String get missionsClaim => 'Reclamar 🎁';

  @override
  String get missionsActiveSectionTitle => 'Missions actives';

  @override
  String get missionsClaimedSectionTitle => 'Ja reclamades';

  @override
  String get missionsTagClaimed => 'Reclamada';

  @override
  String get missionsInProgress => 'En curs';

  @override
  String get missionsRewardCoins => 'monedes';

  @override
  String get friends => 'Amics';

  @override
  String get sent => 'Enviades';

  @override
  String get received => 'Rebudes';

  @override
  String get sendFriendRequestTooltip => 'Enviar sol·licitud d\'amistat';

  @override
  String friendsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count amics',
      one: '1 amic',
    );
    return '$_temp0';
  }

  @override
  String friendsCountWithRequests(int friends, int requests) {
    String _temp0 = intl.Intl.pluralLogic(
      friends,
      locale: localeName,
      other: '$friends amics',
      one: '1 amic',
    );
    String _temp1 = intl.Intl.pluralLogic(
      requests,
      locale: localeName,
      other: '$requests sol·licituds',
      one: '1 sol·licitud',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get noFriendsYet =>
      'Encara no tens amics.\nAfegeix-ne amb el botó superior!';

  @override
  String get noSentRequests => 'No tens cap sol·licitud enviada pendent.';

  @override
  String get noReceivedRequests =>
      'No tens cap sol·licitud d\'amistat pendent.';

  @override
  String get cancel => 'Cancel·lar';

  @override
  String get accept => 'Acceptar';

  @override
  String get reject => 'Rebutjar';

  @override
  String get addFriend => 'Afegir amic';

  @override
  String get addFriendSubtitle => 'Busca un usuari i envia-li una sol·licitud.';

  @override
  String get usernameHint => 'Nom d\'usuari...';

  @override
  String get visitGarden => 'Visita el seu jardí';

  @override
  String get sendRequest => 'Enviar sol·licitud';

  @override
  String get tryAgain => 'Tornar a intentar';

  @override
  String get gardenLoadError => 'No s\'ha pogut carregar el jardí.';

  @override
  String get emptyFriendGarden => 'Aquest jardí no té testos.';

  @override
  String get likeGarden => 'Fer m\'agrada';

  @override
  String get likedGarden => 'M\'agrada fet';

  @override
  String get close => 'Tancar';

  @override
  String get friendOptions => 'Opcions de l\'amic';

  @override
  String get deleteFriend => 'Eliminar amic';

  @override
  String get deleteFriendTitle => 'Eliminar amic';

  @override
  String deleteFriendMessage(String username) {
    return 'Segur que vols eliminar @$username de la teva llista d\'amics?';
  }

  @override
  String get delete => 'Eliminar';

  @override
  String get friendRequestSentSuccessfully =>
      'Sol·licitud enviada correctament';
}
