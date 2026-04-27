// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MeteoGarden';

  @override
  String get commonBack => 'Back';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonCity => 'City';

  @override
  String get commonClose => 'Close';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonDescription => 'Description';

  @override
  String get commonLanguage => 'Language';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonSave => 'Save';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonEliminar => 'Delete';

  @override
  String get loginWelcomeTitle => 'Welcome to MeteoGarden';

  @override
  String get loginWelcomeSubtitle =>
      'Log in to continue taking care of your garden.';

  @override
  String get loginUsernameLabel => 'Username';

  @override
  String get loginUsernameHint => 'Enter your username';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginPasswordHint => 'Enter your password';

  @override
  String get loginButton => 'Log in';

  @override
  String get loginContinueWith => 'or continue with';

  @override
  String get loginNoAccount => 'Don\'t have an account?';

  @override
  String get loginCreateAccount => 'Create account';

  @override
  String get loginError => 'Login error';

  @override
  String get loginGoogleError => 'Google login error';

  @override
  String get profileLoadError => 'Could not load profile';

  @override
  String get navGarden => 'Garden';

  @override
  String get navFriends => 'Friends';

  @override
  String get navCamera => 'Camera';

  @override
  String get navMissions => 'Missions';

  @override
  String get navProfile => 'Profile';

  @override
  String get albumTitle => 'My plant album';

  @override
  String get albumDiscoveredPlants => 'Plantes descobertes';

  @override
  String get albumLoadingEncyclopedia => 'Consulting encyclopedia...';

  @override
  String albumDetailsLoadError(String error) {
    return 'Error loading details: $error';
  }

  @override
  String get albumUnknownPlant => 'Unknown';

  @override
  String get albumNoDescription => 'No description available.';

  @override
  String get albumFamilyLabel => 'Family';

  @override
  String get albumBlooms => 'Blooms';

  @override
  String get albumDoesNotBloom => 'Does not bloom';

  @override
  String get albumDescriptionTitle => 'Description';

  @override
  String get albumEmptyState =>
      'You haven\'t discovered any plants yet 🌱\nKeep exploring!';

  @override
  String get albumPlantInfoLoadError => 'Error loading plant information';

  @override
  String get shopTitle => 'Shop';

  @override
  String get shopSeedsTab => 'Seeds 🌱';

  @override
  String get shopOtherTab => 'Other 🛒';

  @override
  String get shopLoadError => 'Could not load products.';

  @override
  String get shopConnectionError =>
      'Connection error or error processing data.';

  @override
  String get shopPurchaseProcessingError => 'Error processing purchase.';

  @override
  String get shopPurchaseSuccess => 'Purchase completed successfully! 🌱';

  @override
  String get shopTotalPrice => 'Total price:';

  @override
  String get shopBuyButton => 'Buy';

  @override
  String get shopNoItemsAvailable => 'No items available right now.';

  @override
  String get calendarUpcomingEvents => 'Upcoming events';

  @override
  String get calendarNoEventsThisMonth => 'There are no events this month';

  @override
  String get calendarClearFilters => 'Clear filters';

  @override
  String get calendarNoEventsThisDay => 'No events on this day';

  @override
  String get calendarFiltersTitle => 'Filters';

  @override
  String get calendarClearAll => 'Clear all';

  @override
  String get calendarSearchTextLabel => 'Search by text';

  @override
  String get calendarSearchTextHint => 'Name, description...';

  @override
  String get calendarCityLabel => 'City';

  @override
  String get calendarCityHint => 'Barcelona, Girona...';

  @override
  String get calendarCountyLabel => 'County';

  @override
  String get calendarCountyHint => 'Osona, Maresme...';

  @override
  String get calendarCategoryLabel => 'Category';

  @override
  String get calendarCategoryHint => 'Market, Concert, Route...';

  @override
  String get calendarMaxDistanceLabel => 'Maximum distance';

  @override
  String get calendarMaxPriceLabel => 'Maximum price';

  @override
  String get calendarApplyFilters => 'Apply filters';

  @override
  String get calendarFree => 'Free';

  @override
  String get calendarFreeAccent => 'Free';

  @override
  String get calendarBuyTickets => 'Buy tickets';

  @override
  String get calendarEventSingular => 'event';

  @override
  String get calendarEventPlural => 'events';

  @override
  String calendarEventsCount(Object count) {
    return '$count events';
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
  String get weekdayMon => 'Mon';

  @override
  String get weekdayTue => 'Tue';

  @override
  String get weekdayWed => 'Wed';

  @override
  String get weekdayThu => 'Thu';

  @override
  String get weekdayFri => 'Fri';

  @override
  String get weekdaySat => 'Sat';

  @override
  String get weekdaySun => 'Sun';

  @override
  String get monthJanuary => 'January';

  @override
  String get monthFebruary => 'February';

  @override
  String get monthMarch => 'March';

  @override
  String get monthApril => 'April';

  @override
  String get monthMay => 'May';

  @override
  String get monthJune => 'June';

  @override
  String get monthJuly => 'July';

  @override
  String get monthAugust => 'August';

  @override
  String get monthSeptember => 'September';

  @override
  String get monthOctober => 'October';

  @override
  String get monthNovember => 'November';

  @override
  String get monthDecember => 'December';

  @override
  String get monthShortJanuary => 'Jan';

  @override
  String get monthShortFebruary => 'Feb';

  @override
  String get monthShortMarch => 'Mar';

  @override
  String get monthShortApril => 'Apr';

  @override
  String get monthShortMay => 'May';

  @override
  String get monthShortJune => 'Jun';

  @override
  String get monthShortJuly => 'Jul';

  @override
  String get monthShortAugust => 'Aug';

  @override
  String get monthShortSeptember => 'Sep';

  @override
  String get monthShortOctober => 'Oct';

  @override
  String get monthShortNovember => 'Nov';

  @override
  String get monthShortDecember => 'Dec';

  @override
  String get photoNoCameraAvailable => 'No camera available.';

  @override
  String get photoCameraInitError => 'Could not initialize camera.';

  @override
  String get photoUnexpectedError => 'An unexpected error occurred.';

  @override
  String get photoTakePlantPicture => 'Take a picture of the plant';

  @override
  String get photoTreeMode => 'Tree';

  @override
  String get photoFlowerMode => 'Flower';

  @override
  String get photoTreeModeSelected => 'Tree mode selected';

  @override
  String get photoFlowerModeSelected => 'Flower mode selected';

  @override
  String get photoIdentifyingPlant => 'Identifying plant...';

  @override
  String get photoCenterPlantInFrame => 'Center the plant within the frame';

  @override
  String get plantResultTitle => 'Identified plant';

  @override
  String get plantResultScientificName => 'Scientific name';

  @override
  String get plantResultFamily => 'Family';

  @override
  String get plantResultConfidence => 'Confidence';

  @override
  String get plantResultTakeAnotherPhoto => 'Take another photo';

  @override
  String get profileStatsTitle => 'Statistics';

  @override
  String get profileDefaultUser => 'User';

  @override
  String get profileCityNotDefined => 'City not defined';

  @override
  String get profileCoins => 'Coins';

  @override
  String get profileDiscovered => 'Discovered';

  @override
  String get profileUserLabel => 'User';

  @override
  String get profileEmailLabel => 'Email';

  @override
  String get profileCityLabel => 'City';

  @override
  String get profileLanguageLabel => 'Language';

  @override
  String get profileEditButton => 'Edit profile';

  @override
  String get profilePlants => 'Plants';

  @override
  String get profileLogout => 'Log out';

  @override
  String get profileDeleteAccountTitle => 'Delete account';

  @override
  String get profileDeleteAccountMessage =>
      'Are you sure you want to delete your account? This action is permanent and all your coins and discovered plants will be lost.';

  @override
  String get profileDeleteAccountError => 'Error deleting account';

  @override
  String get profileDeleteAccountConfirm => 'Yes, delete';

  @override
  String get createAccountTitle => 'Create account';

  @override
  String get createAccountWelcome => 'Welcome to Meteo Garden';

  @override
  String get createAccountSubtitle => 'Fill in your details to get started';

  @override
  String get createAccountEmailLabel => 'Email';

  @override
  String get createAccountGardenNameLabel => 'Your garden\'s name';

  @override
  String get createAccountSuccess => 'Account created successfully!';

  @override
  String get createAccountError => 'Error creating account';

  @override
  String get completeProfileTitle => 'Complete profile';

  @override
  String get completeProfileHeading => 'We\'re almost there!';

  @override
  String get completeProfileSubtitle =>
      'Complete this information to finish registering with Google';

  @override
  String get completeProfilePasswordOptional => 'Password (Optional)';

  @override
  String get completeProfileSuccess => 'Account completed successfully!';

  @override
  String get completeProfileError => 'Error completing profile';

  @override
  String get profileEditTitle => 'Edit profile';

  @override
  String get profileEditUserDataTitle => 'User data';

  @override
  String get profileEditUpdated => 'Profile updated';

  @override
  String get profileEditUpdateError => 'Error updating profile';

  @override
  String get languageCatalan => 'Catalan';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languageEnglish => 'English';

  @override
  String get inventoryTitle => 'Your inventory';

  @override
  String get inventorySearchHint => 'Search for a seed or potion...';

  @override
  String get inventorySeedsTab => 'Seeds';

  @override
  String get inventoryPotionsTab => 'Potions';

  @override
  String get inventoryNoSeeds => 'No seeds available';

  @override
  String get inventoryNoPotions => 'No potions available';

  @override
  String inventoryAvailableItems(Object count) {
    return '$count items available';
  }

  @override
  String inventoryQuantity(Object amount) {
    return 'Quantity: $amount';
  }

  @override
  String get gardenLoadingSeedsError => 'Error loading seeds';

  @override
  String get gardenLoadingWeather => 'Loading weather...';

  @override
  String get gardenWaitMoment => 'Wait a moment';

  @override
  String get gardenWeatherLoadError => 'Could not load weather';

  @override
  String get gardenTapToRetry => 'Tap to try again';

  @override
  String get gardenLoadingPotsError => 'Error loading pots:';

  @override
  String get gardenNoPotsAvailable => 'No pots available';

  @override
  String gardenWeatherSummary(Object temp, Object precipitation) {
    return 'Temperature: $temp°C | Precipitation: $precipitation';
  }

  @override
  String gardenWindSummary(Object wind) {
    return 'Wind: $wind m/s';
  }

  @override
  String get waterlabel => 'Water Level';

  @override
  String get salut => 'Health';

  @override
  String get lastReg => 'Last watered: ';

  @override
  String get regar => 'Water plant';

  @override
  String get recolectPlant => 'Collect plant';

  @override
  String get aplyPotion => 'Apply potion';

  @override
  String get selectPotion => 'Select a potion for the pot';

  @override
  String get errorPotions => 'Error loading potions';

  @override
  String get readyPotion => 'Potion available to apply';

  @override
  String get aplyingPotion => 'Applying...';

  @override
  String get noPotions => 'You have no potions available';

  @override
  String get extraPotions =>
      'When you get some, you will be able to apply them here.';

  @override
  String get testbuit => 'Empty pot';

  @override
  String get selectionLlavor => 'Select a seed for the pot';

  @override
  String get llavorDisp => 'Seed available for planting';

  @override
  String get plant => 'Plant';

  @override
  String get planting => 'Planting...';

  @override
  String get noLlavor => 'You have no seeds available';

  @override
  String get extraLlavor =>
      'When you get some, you will be able to plant them here.';

  @override
  String confirmDeletePlant(Object plantName) {
    return 'Are you sure you want to delete $plantName?\nThis action cannot be undone.';
  }

  @override
  String get thisPlant => 'this plant';

  @override
  String get deletePlant => 'Delete plant';

  @override
  String get finalitza => 'Ends on';
}
