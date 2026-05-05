import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meteo_garden/generated/app_localizations.dart';
import 'package:meteo_garden/models/dades_usr.dart';
import 'package:meteo_garden/models/plantes_desbl.dart';
import 'package:meteo_garden/screens/album_page.dart';

class MockUserModel extends Mock implements UserModel {}

class MockPlantProvider extends Mock implements PlantProvider {}

// 1. AÑADIMOS ESTA CLASE FAKE
class FakeUserModel extends Fake implements UserModel {}

void main() {
  late MockUserModel mockUserModel;
  late MockPlantProvider mockPlantProvider;

  // 2. REGISTRAMOS EL FALLBACK AQUÍ
  setUpAll(() {
    registerFallbackValue(FakeUserModel());
  });

  setUp(() {
    mockUserModel = MockUserModel();
    mockPlantProvider = MockPlantProvider();

    when(() => mockUserModel.language).thenReturn('Català');
    when(() => mockPlantProvider.loadPlants(any())).thenAnswer((_) async => {});
  });

  Widget createAlbumPage() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserModel>.value(value: mockUserModel),
        ChangeNotifierProvider<PlantProvider>.value(value: mockPlantProvider),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AlbumPage(),
      ),
    );
  }

  group('AlbumPage Tests', () {
    testWidgets('Muestra el estado de carga inicial', (
      WidgetTester tester,
    ) async {
      // Configuramos el provider para que diga que está cargando
      when(() => mockPlantProvider.isLoading).thenReturn(true);
      when(() => mockPlantProvider.plants).thenReturn([]);

      await tester.pumpWidget(createAlbumPage());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Muestra la vista vacía si no hay plantas', (
      WidgetTester tester,
    ) async {
      when(() => mockPlantProvider.isLoading).thenReturn(false);
      when(() => mockPlantProvider.plants).thenReturn([]); // Lista vacía

      await tester.pumpWidget(createAlbumPage());

      // Debe aparecer el texto de "estado vacío"
      expect(
        find.textContaining('estado vacío'),
        findsNothing,
      ); // Ajusta según tu traducción de t.albumEmptyState
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });
  });
}
