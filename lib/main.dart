import 'package:flutter/material.dart';
import 'package:meteo_garden/models/avatar_user.dart';
import 'package:provider/provider.dart';
import 'package:meteo_garden/screens/login_persistencia.dart';
import 'package:meteo_garden/models/dades_usr.dart';
import 'package:meteo_garden/models/plantes_desbl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:meteo_garden/generated/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:meteo_garden/models/weather_provider.dart';
import 'package:meteo_garden/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserModel()),
        ChangeNotifierProvider(create: (_) => PlantProvider()),
        ChangeNotifierProvider(create: (_) => AvatarUser()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
      ],
      child: const MeteoGardenApp(),
    ),
  );
}

class MeteoGardenApp extends StatelessWidget {
  const MeteoGardenApp({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context);

    Locale? appLocale;
    if (user.language == 'ca' ||
        user.language == 'es' ||
        user.language == 'en') {
      appLocale = Locale(user.language);
    }

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      locale: appLocale,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ca'), Locale('es'), Locale('en')],
      home: const SplashScreen(),
    );
  }
}
