import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meteo_garden/generated/app_localizations.dart';
import 'package:meteo_garden/models/dades_usr.dart';
import 'package:meteo_garden/models/perfil_info.dart';
import 'package:meteo_garden/screens/perfil_edit_page.dart';

class MockUserModel extends Mock implements UserModel {}

void main() {
  late MockUserModel mockUserModel;
  late PerfilInfo fakeProfile;

  setUp(() {
    mockUserModel = MockUserModel();
    when(() => mockUserModel.token).thenReturn('fake-token');

    // Perfil falso para inicializar la vista
    fakeProfile = PerfilInfo(
      username: 'JardineroFiel',
      email: 'test@test.com',
      city: 'Barcelona',
      language: 'ca',
      coins: 50,
      plantsDiscovered: 5,
      // Añade los campos requeridos por tu modelo PerfilInfo
    );
  });

  Widget createPerfilEditPage() {
    return ChangeNotifierProvider<UserModel>.value(
      value: mockUserModel,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PerfilEditPage(profile: fakeProfile),
      ),
    );
  }

  group('PerfilEditPage Tests', () {
    testWidgets('Carga el username inicial en el TextField', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createPerfilEditPage());

      // AÑADIR ESTO: Espera a que desaparezca el CircularProgressIndicator
      await tester.pumpAndSettle();

      // Ahora sí encontrará el TextField
      final usernameField = find.byType(TextField).first;
      expect(usernameField, findsOneWidget);

      final TextField textFieldWidget = tester.widget(usernameField);
      expect(textFieldWidget.controller?.text, 'JardineroFiel');
    });

    testWidgets('Muestra el botón de guardar', (WidgetTester tester) async {
      await tester.pumpWidget(createPerfilEditPage());

      // AÑADIR ESTO: Espera a que termine la carga inicial
      await tester.pumpAndSettle();

      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.byIcon(Icons.save_rounded), findsOneWidget);
    });
  });
}
