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
  String get commonBack => 'Volver';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonCity => 'Ciudad';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonContinue => 'Continuar';

  @override
  String get commonDescription => 'Descripción';

  @override
  String get commonLanguage => 'Idioma';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonSearch => 'Buscar';

  @override
  String get commonEliminar => 'Eliminar';

  @override
  String get loginWelcomeTitle => 'Bienvenida a MeteoGarden';

  @override
  String get loginWelcomeSubtitle =>
      'Inicia sesión para seguir cuidando tu jardín.';

  @override
  String get loginUsernameLabel => 'Nombre de usuario';

  @override
  String get loginUsernameHint => 'Introduce tu nombre de usuario';

  @override
  String get loginPasswordLabel => 'Contraseña';

  @override
  String get loginPasswordHint => 'Introduce tu contraseña';

  @override
  String get loginButton => 'Iniciar sesión';

  @override
  String get loginContinueWith => 'o continuar con';

  @override
  String get loginNoAccount => '¿No tienes cuenta?';

  @override
  String get loginCreateAccount => 'Crear cuenta';

  @override
  String get loginError => 'Error de inicio de sesión';

  @override
  String get loginGoogleError => 'Error de inicio de sesión con Google';

  @override
  String get profileLoadError => 'No se ha podido cargar el perfil';

  @override
  String get navGarden => 'Jardín';

  @override
  String get navFriends => 'Amigos';

  @override
  String get navCamera => 'Cámara';

  @override
  String get navMissions => 'Misiones';

  @override
  String get navProfile => 'Perfil';

  @override
  String get albumTitle => 'Mi álbum de plantas';

  @override
  String get albumDiscoveredPlants => 'Plantas descubiertas';

  @override
  String get albumLoadingEncyclopedia => 'Consultando enciclopedia...';

  @override
  String albumDetailsLoadError(String error) {
    return 'Error cargando detalles: $error';
  }

  @override
  String get albumUnknownPlant => 'Desconocida';

  @override
  String get albumNoDescription => 'No hay descripción disponible.';

  @override
  String get albumFamilyLabel => 'Familia';

  @override
  String get albumBlooms => 'Florece';

  @override
  String get albumDoesNotBloom => 'No florece';

  @override
  String get albumDescriptionTitle => 'Descripción';

  @override
  String get albumEmptyState =>
      'Todavía no has descubierto ninguna planta 🌱\n¡Sigue explorando!';

  @override
  String get albumPlantInfoLoadError =>
      'Error cargando la información de la planta';

  @override
  String get albumNumber => 'plantas descubiertas';

  @override
  String get shopTitle => 'Tienda';

  @override
  String get shopSeedsTab => 'Semillas 🌱';

  @override
  String get shopOtherTab => 'Otros 🛒';

  @override
  String get shopLoadError => 'No se han podido cargar los productos.';

  @override
  String get shopConnectionError => 'Error de conexión o procesando los datos.';

  @override
  String get shopPurchaseProcessingError => 'Error al procesar la compra.';

  @override
  String get shopPurchaseSuccess => '¡Compra realizada con éxito! 🌱';

  @override
  String get shopTotalPrice => 'Precio total:';

  @override
  String get shopBuyButton => 'Comprar';

  @override
  String get shopNoItemsAvailable =>
      'No hay artículos disponibles ahora mismo.';

  @override
  String get calendarUpcomingEvents => 'Próximos eventos';

  @override
  String get calendarNoEventsThisMonth => 'No hay eventos este mes';

  @override
  String get calendarClearFilters => 'Eliminar filtros';

  @override
  String get calendarNoEventsThisDay => 'Sin eventos este día';

  @override
  String get calendarFiltersTitle => 'Filtros';

  @override
  String get calendarClearAll => 'Limpiar todo';

  @override
  String get calendarSearchTextLabel => 'Buscar por texto';

  @override
  String get calendarSearchTextHint => 'Nombre, descripción...';

  @override
  String get calendarCityLabel => 'Ciudad';

  @override
  String get calendarCityHint => 'Barcelona, Girona...';

  @override
  String get calendarCountyLabel => 'Comarca';

  @override
  String get calendarCountyHint => 'Osona, Maresme...';

  @override
  String get calendarCategoryLabel => 'Categoría';

  @override
  String get calendarCategoryHint => 'Mercado, Concierto, Ruta...';

  @override
  String get calendarMaxDistanceLabel => 'Distancia máxima';

  @override
  String get calendarMaxPriceLabel => 'Precio máximo';

  @override
  String get calendarApplyFilters => 'Aplicar filtros';

  @override
  String get calendarFree => 'Gratis';

  @override
  String get calendarFreeAccent => 'Gratuito';

  @override
  String get calendarBuyTickets => 'Comprar entradas';

  @override
  String get calendarEventSingular => 'evento';

  @override
  String get calendarEventPlural => 'eventos';

  @override
  String calendarEventsCount(Object count) {
    return '$count eventos';
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
  String get weekdayMon => 'Lun';

  @override
  String get weekdayTue => 'Mar';

  @override
  String get weekdayWed => 'Mié';

  @override
  String get weekdayThu => 'Jue';

  @override
  String get weekdayFri => 'Vie';

  @override
  String get weekdaySat => 'Sáb';

  @override
  String get weekdaySun => 'Dom';

  @override
  String get monthJanuary => 'Enero';

  @override
  String get monthFebruary => 'Febrero';

  @override
  String get monthMarch => 'Marzo';

  @override
  String get monthApril => 'Abril';

  @override
  String get monthMay => 'Mayo';

  @override
  String get monthJune => 'Junio';

  @override
  String get monthJuly => 'Julio';

  @override
  String get monthAugust => 'Agosto';

  @override
  String get monthSeptember => 'Septiembre';

  @override
  String get monthOctober => 'Octubre';

  @override
  String get monthNovember => 'Noviembre';

  @override
  String get monthDecember => 'Diciembre';

  @override
  String get monthShortJanuary => 'ene';

  @override
  String get monthShortFebruary => 'feb';

  @override
  String get monthShortMarch => 'mar';

  @override
  String get monthShortApril => 'abr';

  @override
  String get monthShortMay => 'may';

  @override
  String get monthShortJune => 'jun';

  @override
  String get monthShortJuly => 'jul';

  @override
  String get monthShortAugust => 'ago';

  @override
  String get monthShortSeptember => 'sep';

  @override
  String get monthShortOctober => 'oct';

  @override
  String get monthShortNovember => 'nov';

  @override
  String get monthShortDecember => 'dic';

  @override
  String get photoNoCameraAvailable =>
      'No se ha encontrado ninguna cámara disponible.';

  @override
  String get photoCameraInitError => 'No se ha podido inicializar la cámara.';

  @override
  String get photoUnexpectedError => 'Se ha producido un error inesperado.';

  @override
  String get photoTakePlantPicture => 'Fotografía la planta';

  @override
  String get photoTreeMode => 'Hoja';

  @override
  String get photoFlowerMode => 'Flor';

  @override
  String get photoTreeModeSelected => 'Modo hoja seleccionado';

  @override
  String get photoFlowerModeSelected => 'Modo flor seleccionado';

  @override
  String get photoIdentifyingPlant => 'Identificando planta...';

  @override
  String get photoCenterPlantInFrame => 'Centra la planta dentro del marco';

  @override
  String get plantResultTitle => 'Planta identificada';

  @override
  String get plantResultScientificName => 'Nombre científico';

  @override
  String get plantResultFamily => 'Familia';

  @override
  String get plantResultConfidence => 'Confianza';

  @override
  String get plantResultTakeAnotherPhoto => 'Hacer otra foto';

  @override
  String get profileStatsTitle => 'Estadísticas';

  @override
  String get profileDefaultUser => 'Usuario';

  @override
  String get profileCityNotDefined => 'Ciudad no definida';

  @override
  String get profileCoins => 'Monedas';

  @override
  String get profileDiscovered => 'Descubiertas';

  @override
  String get profileUserLabel => 'Usuario';

  @override
  String get profileEmailLabel => 'Email';

  @override
  String get profileCityLabel => 'Ciudad';

  @override
  String get profileLanguageLabel => 'Idioma';

  @override
  String get profileEditButton => 'Modificar perfil';

  @override
  String get profilePlants => 'Plantas';

  @override
  String get profileLogout => 'Cerrar sesión';

  @override
  String get profileDeleteAccountTitle => 'Eliminar cuenta';

  @override
  String get profileDeleteAccountMessage =>
      '¿Estás seguro de que quieres eliminar tu cuenta? Esta acción es permanente y se perderán todas tus monedas y plantas descubiertas.';

  @override
  String get profileDeleteAccountError => 'Error eliminando la cuenta';

  @override
  String get profileDeleteAccountConfirm => 'Sí, eliminar';

  @override
  String get createAccountTitle => 'Crear cuenta';

  @override
  String get createAccountWelcome => 'Bienvenido a Meteo Garden';

  @override
  String get createAccountSubtitle => 'Rellena tus datos para empezar';

  @override
  String get createAccountEmailLabel => 'Correo electrónico';

  @override
  String get createAccountGardenNameLabel => 'Nombre de tu jardín';

  @override
  String get createAccountSuccess => '¡Cuenta creada correctamente!';

  @override
  String get createAccountError => 'Error creando la cuenta';

  @override
  String get completeProfileTitle => 'Completar perfil';

  @override
  String get completeProfileHeading => '¡Ya casi lo tenemos!';

  @override
  String get completeProfileSubtitle =>
      'Completa estos datos para finalizar el registro con Google';

  @override
  String get completeProfilePasswordOptional => 'Contraseña (Opcional)';

  @override
  String get completeProfileSuccess => '¡Cuenta completada correctamente!';

  @override
  String get completeProfileError => 'Error completando perfil';

  @override
  String get profileEditTitle => 'Modificar perfil';

  @override
  String get profileEditUserDataTitle => 'Datos de usuario';

  @override
  String get profileEditUpdated => 'Perfil actualizado';

  @override
  String get profileEditUpdateError => 'Error actualizando el perfil';

  @override
  String get languageCatalan => 'Catalán';

  @override
  String get languageSpanish => 'Castellano';

  @override
  String get languageEnglish => 'English';

  @override
  String get inventoryTitle => 'Tu inventario';

  @override
  String get inventorySearchHint => 'Busca una semilla o poción...';

  @override
  String get inventorySeedsTab => 'Semillas';

  @override
  String get inventoryPotionsTab => 'Pociones';

  @override
  String get inventoryNoSeeds => 'No hay semillas disponibles';

  @override
  String get inventoryNoPotions => 'No hay pociones disponibles';

  @override
  String inventoryAvailableItems(Object count) {
    return '$count elementos disponibles';
  }

  @override
  String inventoryQuantity(Object amount) {
    return 'Cantidad: $amount';
  }

  @override
  String get gardenLoadingSeedsError => 'Error cargando semillas';

  @override
  String get gardenLoadingWeather => 'Cargando meteo...';

  @override
  String get gardenWaitMoment => 'Espera un momento';

  @override
  String get gardenWeatherLoadError => 'No se ha podido cargar la meteo';

  @override
  String get gardenTapToRetry => 'Toca para volver a intentarlo';

  @override
  String get gardenLoadingPotsError => 'Error cargando las macetas:';

  @override
  String get gardenNoPotsAvailable => 'No hay macetas disponibles';

  @override
  String gardenWeatherSummary(Object temp, Object precipitation) {
    return 'Temperatura: $temp°C | Precipitación: $precipitation';
  }

  @override
  String gardenWindSummary(Object wind) {
    return 'Viento: $wind m/s';
  }

  @override
  String get waterlabel => 'Nivel de agua';

  @override
  String get salut => 'Salud';

  @override
  String get lastReg => 'Último riego: ';

  @override
  String get regar => 'Regar planta';

  @override
  String get recolectPlant => 'Recolectar planta';

  @override
  String get aplyPotion => 'Aplicar poción';

  @override
  String get selectPotion => 'Selecciona una poción para la maceta';

  @override
  String get errorPotions => 'Error cargando pociones';

  @override
  String get readyPotion => 'Poción disponible para aplicar';

  @override
  String get aplyingPotion => 'Aplicando...';

  @override
  String get noPotions => 'No tienes pociones disponibles';

  @override
  String get extraPotions => 'Cuando consigas, podrás aplicarlas aquí.';

  @override
  String get testbuit => 'Maceta vacía';

  @override
  String get selectionLlavor => 'Selecciona una semilla para la maceta';

  @override
  String get llavorDisp => 'Semilla disponible para plantar';

  @override
  String get plant => 'Plantar';

  @override
  String get planting => 'Plantando...';

  @override
  String get noLlavor => 'No tienes semillas disponibles';

  @override
  String get extraLlavor => 'Cuando consigas, podrás plantarlas aquí.';

  @override
  String confirmDeletePlant(Object plantName) {
    return '¿Estás seguro de que quieres eliminar $plantName?\nEsta acción no se puede deshacer.';
  }

  @override
  String get thisPlant => 'esta planta';

  @override
  String get deletePlant => 'Eliminar planta';

  @override
  String get finalitza => 'Finaliza el';

  @override
  String get avatarLoadError => 'Error cargando el avatar';

  @override
  String get createYourAvatar => 'Create your Avatar';

  @override
  String get editAvatar => 'Editar avatar';

  @override
  String get errorLoadingOptions => 'Error cargando las opciones';

  @override
  String get errorConnectionOptions =>
      'Error de conexión cargando las opciones.';

  @override
  String get errorConnectionAvatar => 'Error de conexión cargando el avatar.';

  @override
  String get errorSavingAvatar => 'Error guardando el avatar';

  @override
  String get errorConnectionSaving => 'Error de conexión guardando el avatar.';

  @override
  String get noOptionsAvailable => 'No hay opciones disponibles';

  @override
  String get continueButton => 'Continuar';

  @override
  String get saveChangesButton => 'Guardar cambios';

  @override
  String get categoryBody => 'Cuerpo';

  @override
  String get categoryEyes => 'Ojos';

  @override
  String get categoryExpression => 'Expresión';

  @override
  String get categoryHair => 'Cabello';

  @override
  String get categoryFacialHair => 'Barba';

  @override
  String get categoryClothing => 'Ropa';

  @override
  String get categoryAccessories => 'Accesorios';

  @override
  String get errorMessageSession => 'Error iniciando sessión';

  @override
  String get connectionError => 'Error de connexión';

  @override
  String get allCities => 'Todas las ciudades';

  @override
  String get noEventsToday => 'No hi ha events aquest dia';

  @override
  String get phaseSeed => 'Semilla';

  @override
  String get phaseGermination => 'Germinación';

  @override
  String get phaseGrowth => 'Crecimiento';

  @override
  String get phaseMature => 'Madura';

  @override
  String get phaseFlowering => 'Floración';

  @override
  String get phaseDead => 'Muerta';

  @override
  String get avatarLoadErrorPersist => 'Error cargando el avatar';

  @override
  String get filterByCity => 'Filtrar por ciudad';

  @override
  String get writeCity => 'Escribe una ciudad...';

  @override
  String get commonApply => 'Aplicar';

  @override
  String get plantWateredSuccess => 'Planta regada correctamente';

  @override
  String get plantCollectedSuccess => 'Planta recolectada correctamente';

  @override
  String get plantDeletedSuccess => 'Planta eliminada correctamente';

  @override
  String get plantActionError => 'No se ha podido completar la acción';

  @override
  String get plantLoadingSeedsError => 'No se han podido cargar las semillas';

  @override
  String get weatherDetailsTitle => 'Detalles meterológicos';

  @override
  String get weatherStationLabel => 'Estación Metereológica';

  @override
  String get temperatureLabel => 'Temperatura';

  @override
  String get humidityLabel => 'Humidad';

  @override
  String get windLabel => 'Viento';

  @override
  String get precipitationLabel => 'Precipitación';

  @override
  String get solarIrradianceLabel => 'Irradiancia solar';

  @override
  String get missionsTitle => 'Misiones';

  @override
  String get missionsSubtitle => 'Completa retos y gana monedas';

  @override
  String get missionsCompleted => 'Completadas';

  @override
  String get missionsTagCompleted => 'Completada';

  @override
  String get missionsTagInProgress => 'En progreso';

  @override
  String get missionsEmpty => 'No hay misiones disponibles';

  @override
  String get missionsClaimSuccess => '¡Recompensa reclamada!';

  @override
  String get missionsErrorAlreadyClaimed => 'Esta misión ya fue reclamada';

  @override
  String get missionsErrorInProgress => 'La misión todavía no está completada';

  @override
  String get missionsErrorNotFound => 'Misión no encontrada';

  @override
  String get missionsErrorGeneric => 'No se pudo reclamar la recompensa';

  @override
  String get missionsClaim => 'Reclamar 🎁';

  @override
  String get missionsActiveSectionTitle => 'Misiones activas';

  @override
  String get missionsClaimedSectionTitle => 'Ya reclamadas';

  @override
  String get missionsTagClaimed => 'Reclamada';

  @override
  String get missionsInProgress => 'En curso';

  @override
  String get missionsRewardCoins => 'monedas';

  @override
  String get friends => 'Amigos';

  @override
  String get sent => 'Enviadas';

  @override
  String get received => 'Recibidas';

  @override
  String get sendFriendRequestTooltip => 'Enviar solicitud de amistad';

  @override
  String friendsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count amigos',
      one: '1 amigo',
    );
    return '$_temp0';
  }

  @override
  String friendsCountWithRequests(int friends, int requests) {
    String _temp0 = intl.Intl.pluralLogic(
      friends,
      locale: localeName,
      other: '$friends amigos',
      one: '1 amigo',
    );
    String _temp1 = intl.Intl.pluralLogic(
      requests,
      locale: localeName,
      other: '$requests solicitudes',
      one: '1 solicitud',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get noFriendsYet =>
      'Todavía no tienes amigos.\n¡Añade uno con el botón superior!';

  @override
  String get noSentRequests => 'No tienes ninguna solicitud enviada pendiente.';

  @override
  String get noReceivedRequests =>
      'No tienes ninguna solicitud de amistad pendiente.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get accept => 'Aceptar';

  @override
  String get reject => 'Rechazar';

  @override
  String get addFriend => 'Añadir amigo';

  @override
  String get addFriendSubtitle => 'Busca un usuario y envíale una solicitud.';

  @override
  String get usernameHint => 'Nombre de usuario...';

  @override
  String get visitGarden => 'Visita su jardín';

  @override
  String get sendRequest => 'Enviar solicitud';

  @override
  String get tryAgain => 'Volver a intentarlo';

  @override
  String get gardenLoadError => 'No se ha podido cargar el jardín.';

  @override
  String get emptyFriendGarden => 'Este jardín no tiene macetas.';

  @override
  String get likeGarden => 'Dar me gusta';

  @override
  String get likedGarden => 'Me gusta enviado';

  @override
  String get close => 'Cerrar';

  @override
  String get friendOptions => 'Opciones del amigo';

  @override
  String get deleteFriend => 'Eliminar amigo';

  @override
  String get deleteFriendTitle => 'Eliminar amigo';

  @override
  String deleteFriendMessage(String username) {
    return '¿Seguro que quieres eliminar a @$username de tu lista de amigos?';
  }

  @override
  String get delete => 'Eliminar';

  @override
  String get friendRequestSentSuccessfully => 'Solicitud enviada correctamente';
}
