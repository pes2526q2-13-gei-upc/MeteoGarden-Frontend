import 'package:flutter_test/flutter_test.dart';
// Sustituye por la ruta real de tu modelo
import 'package:meteo_garden/models/dades_usr.dart';

void main() {
  group('Pruebas de UserModel (Perfil)', () {
    test(
      'setProfile debe actualizar todas las variables del usuario correctamente',
      () {
        // 1. Preparar: Instanciamos el modelo vacío
        final userModel = UserModel();

        // 2. Ejecutar: Llamamos a la función con datos simulados
        userModel.setProfile(
          newUsername: 'JardineroPro',
          newEmail: 'jardinero@test.com',
          newCity: 'Barcelona',
          newLanguage: 'es',
          newLastEntry: '2026-04-30',
          newNumPlantsCollected: 5,
          newMonedes: 100,
          newGardens: ['Jardín Zen', 'Huerto Urbano'],
        );

        // 3. Comprobar: Verificamos que los datos se han guardado bien en las variables
        expect(userModel.username, 'JardineroPro');
        expect(userModel.email, 'jardinero@test.com');
        expect(userModel.city, 'Barcelona');
        expect(userModel.numPlantsCollected, 5);
        expect(userModel.monedes, 100);
        expect(userModel.gardens.length, 2);
        expect(userModel.gardens.first, 'Jardín Zen');
      },
    );

    test('setToken debe actualizar el token', () {
      final userModel = UserModel();
      userModel.setToken('mi_token_super_seguro_123');

      expect(userModel.token, 'mi_token_super_seguro_123');
    });
  });
}
