import 'package:flutter_test/flutter_test.dart';
import 'package:meteo_garden/models/perfil_info.dart';

void main() {
  group('PerfilInfo', () {
    test('constructor assigna correctament tots els camps', () {
      final perfil = PerfilInfo(
        username: 'jana',
        email: 'jana@example.com',
        city: 'Barcelona',
        language: 'ca',
        coins: 120,
        plantsDiscovered: 8,
      );

      expect(perfil.username, 'jana');
      expect(perfil.email, 'jana@example.com');
      expect(perfil.city, 'Barcelona');
      expect(perfil.language, 'ca');
      expect(perfil.coins, 120);
      expect(perfil.plantsDiscovered, 8);
    });

    test('fromJson converteix correctament un JSON complet', () {
      final perfil = PerfilInfo.fromJson({
        'username': 'laia',
        'email': 'laia@example.com',
        'city': 'Vic',
        'language': 'ca',
        'coins': 75,
        'plants_discovered': 4,
      });

      expect(perfil.username, 'laia');
      expect(perfil.email, 'laia@example.com');
      expect(perfil.city, 'Vic');
      expect(perfil.language, 'ca');
      expect(perfil.coins, 75);
      expect(perfil.plantsDiscovered, 4);
    });

    test('fromJson posa valors per defecte si falten camps', () {
      final perfil = PerfilInfo.fromJson({});

      expect(perfil.username, '');
      expect(perfil.email, '');
      expect(perfil.city, '');
      expect(perfil.language, '');
      expect(perfil.coins, 0);
      expect(perfil.plantsDiscovered, 0);
    });

    test('fromJson converteix strings amb toString', () {
      final perfil = PerfilInfo.fromJson({
        'username': 123,
        'email': true,
        'city': 'Girona',
        'language': 'es',
        'coins': 10,
        'plants_discovered': 2,
      });

      expect(perfil.username, '123');
      expect(perfil.email, 'true');
      expect(perfil.city, 'Girona');
      expect(perfil.language, 'es');
      expect(perfil.coins, 10);
      expect(perfil.plantsDiscovered, 2);
    });

    test('fromJson gestiona camps string null correctament', () {
      final perfil = PerfilInfo.fromJson({
        'username': null,
        'email': null,
        'city': null,
        'language': null,
        'coins': 0,
        'plants_discovered': 0,
      });

      expect(perfil.username, '');
      expect(perfil.email, '');
      expect(perfil.city, '');
      expect(perfil.language, '');
      expect(perfil.coins, 0);
      expect(perfil.plantsDiscovered, 0);
    });
  });
}