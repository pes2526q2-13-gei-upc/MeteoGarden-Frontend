import 'package:flutter/material.dart';
import '../screens/login_page.dart';

class MeteoGardenApp extends StatelessWidget {
  const MeteoGardenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MeteoGarden',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: LoginPage(), //const HomeShell(),
    );
  }
}
