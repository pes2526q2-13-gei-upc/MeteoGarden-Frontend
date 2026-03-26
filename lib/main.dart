import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meteo_garden/screens/login_page.dart';
import 'package:meteo_garden/models/dades_usr.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserModel())],
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
      title: 'MeteoGarden',
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      home: const LoginPage(),
    );
  }
}
