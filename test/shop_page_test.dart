import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meteo_garden/generated/app_localizations.dart';
import 'package:meteo_garden/models/dades_usr.dart';
import 'package:meteo_garden/screens/botiga_page.dart';

// 1. Creamos un Mock del UserModel
class MockUserModel extends Mock implements UserModel {}

void main() {
  late MockUserModel mockUserModel;

  setUp(() {
    mockUserModel = MockUserModel();
    // Comportamiento por defecto del mock
    when(() => mockUserModel.token).thenReturn('fake-token-123');
    when(() => mockUserModel.username).thenReturn('testUser');
  });

  Widget createShopPage() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserModel>.value(value: mockUserModel),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ShopPage(),
      ),
    );
  }

  group('ShopPage Tests', () {
    testWidgets('Muestra el indicador de carga al iniciar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createShopPage());

      // Al arrancar, isLoading es true, por lo que debe haber un CircularProgressIndicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Renderiza las pestañas correctamente', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createShopPage());
      await tester.pumpAndSettle(); // Espera a que termine la animación inicial

      // Verifica que existen las pestañas de Semillas y Otros
      expect(find.byType(TabBar), findsOneWidget);
      expect(find.byType(Tab), findsNWidgets(2));
    });
  });
}
