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
}
