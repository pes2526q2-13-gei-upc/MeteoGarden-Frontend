import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meteo_garden/screens/login_page.dart';
import 'package:meteo_garden/models/dades_usr.dart';
import 'package:meteo_garden/models/plantes_desbl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:meteo_garden/generated/app_localizations.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserModel()),
        ChangeNotifierProvider(create: (_) => PlantProvider()),
      ],
      child: const MeteoGardenApp(),
    ),
  );
}

class MeteoGardenApp extends StatelessWidget {
  const MeteoGardenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ca'),
        Locale('es'),
        Locale('en'),
      ],
      home: const LoginPage(),
    );
  }
}
