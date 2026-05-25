import 'package:flutter_test/flutter_test.dart';
import 'package:meteo_garden/models/dades_usr.dart';

void main() {
  group('UserModel', () {
    test('estat inicial correcte', () {
      final user = UserModel();

      expect(user.username, '');
      expect(user.email, '');
      expect(user.city, '');
      expect(user.language, '');
      expect(user.lastEntry, '');
      expect(user.numPlantsCollected, 0);
      expect(user.monedes, 0);
      expect(user.token, '');
      expect(user.gardens, isEmpty);
      expect(user.gardenName, '');
    });

    test('setToken actualitza el token i notifica listeners', () {
      final user = UserModel();
      var notifyCount = 0;

      user.addListener(() {
        notifyCount++;
      });

      user.setToken('abc123');

      expect(user.token, 'abc123');
      expect(notifyCount, 1);
    });

    test('setEmail actualitza email i notifica listeners', () {
      final user = UserModel();
      var notifyCount = 0;

      user.addListener(() {
        notifyCount++;
      });

      user.setEmail('test@example.com');

      expect(user.email, 'test@example.com');
      expect(notifyCount, 1);
    });

    test('setCoins actualitza monedes i notifica listeners', () {
      final user = UserModel();
      var notifyCount = 0;

      user.addListener(() {
        notifyCount++;
      });

      user.setCoins(50);

      expect(user.monedes, 50);
      expect(notifyCount, 1);
    });

    test(
      'setProfile actualitza totes les dades del perfil i notifica listeners',
      () {
        final user = UserModel();
        var notifyCount = 0;

        user.addListener(() {
          notifyCount++;
        });

        user.setProfile(
          newUsername: 'jana',
          newEmail: 'jana@example.com',
          newCity: 'Barcelona',
          newLanguage: 'ca',
          newLastEntry: '2026-05-16',
          newNumPlantsCollected: 8,
          newMonedes: 120,
          newGardens: ['Jardi principal', 'Jardi secundari'],
        );

        expect(user.username, 'jana');
        expect(user.email, 'jana@example.com');
        expect(user.city, 'Barcelona');
        expect(user.language, 'ca');
        expect(user.lastEntry, '2026-05-16');
        expect(user.numPlantsCollected, 8);
        expect(user.monedes, 120);
        expect(user.gardens, ['Jardi principal', 'Jardi secundari']);
        expect(user.gardenName, 'Jardi principal');
        expect(notifyCount, 1);
      },
    );

    test('gardenName retorna buit si no hi ha jardins', () {
      final user = UserModel();

      expect(user.gardens, isEmpty);
      expect(user.gardenName, '');
    });

    test('gardenName retorna el primer jardí si existeix', () {
      final user = UserModel();

      user.setProfile(
        newUsername: 'jana',
        newEmail: 'jana@example.com',
        newCity: 'Barcelona',
        newLanguage: 'ca',
        newLastEntry: '2026-05-16',
        newNumPlantsCollected: 3,
        newMonedes: 40,
        newGardens: ['Jardi 1', 'Jardi 2'],
      );

      expect(user.gardenName, 'Jardi 1');
    });

    test('updateProfile actualitza només els camps indicats', () {
      final user = UserModel();

      user.setProfile(
        newUsername: 'jana',
        newEmail: 'jana@example.com',
        newCity: 'Barcelona',
        newLanguage: 'ca',
        newLastEntry: '2026-05-16',
        newNumPlantsCollected: 8,
        newMonedes: 120,
        newGardens: ['Jardi principal'],
      );

      user.updateProfile(newUsername: 'laia', newCity: 'Vic');

      expect(user.username, 'laia');
      expect(user.city, 'Vic');

      // Aquests camps no haurien de canviar.
      expect(user.email, 'jana@example.com');
      expect(user.language, 'ca');
      expect(user.lastEntry, '2026-05-16');
      expect(user.numPlantsCollected, 8);
      expect(user.monedes, 120);
      expect(user.gardens, ['Jardi principal']);
    });

    test('updateProfile notifica listeners', () {
      final user = UserModel();
      var notifyCount = 0;

      user.addListener(() {
        notifyCount++;
      });

      user.updateProfile(
        newUsername: 'jana',
        newCity: 'Barcelona',
        newLanguage: 'ca',
      );

      expect(user.username, 'jana');
      expect(user.city, 'Barcelona');
      expect(user.language, 'ca');
      expect(notifyCount, 1);
    });

    test('clearUser reinicia totes les dades i notifica listeners', () {
      final user = UserModel();
      var notifyCount = 0;

      user.setProfile(
        newUsername: 'jana',
        newEmail: 'jana@example.com',
        newCity: 'Barcelona',
        newLanguage: 'ca',
        newLastEntry: '2026-05-16',
        newNumPlantsCollected: 8,
        newMonedes: 120,
        newGardens: ['Jardi principal'],
      );
      user.setToken('token123');

      user.addListener(() {
        notifyCount++;
      });

      user.clearUser();

      expect(user.username, '');
      expect(user.email, '');
      expect(user.city, '');
      expect(user.language, '');
      expect(user.lastEntry, '');
      expect(user.numPlantsCollected, 0);
      expect(user.monedes, 0);
      expect(user.token, '');
      expect(user.gardens, isEmpty);
      expect(user.gardenName, '');
      expect(notifyCount, 1);
    });

    test('logout reinicia totes les dades i notifica listeners', () {
      final user = UserModel();
      var notifyCount = 0;

      user.setProfile(
        newUsername: 'jana',
        newEmail: 'jana@example.com',
        newCity: 'Barcelona',
        newLanguage: 'ca',
        newLastEntry: '2026-05-16',
        newNumPlantsCollected: 8,
        newMonedes: 120,
        newGardens: ['Jardi principal'],
      );
      user.setToken('token123');

      user.addListener(() {
        notifyCount++;
      });

      user.logout();

      expect(user.username, '');
      expect(user.email, '');
      expect(user.city, '');
      expect(user.language, '');
      expect(user.lastEntry, '');
      expect(user.numPlantsCollected, 0);
      expect(user.monedes, 0);
      expect(user.token, '');
      expect(user.gardens, isEmpty);
      expect(user.gardenName, '');
      expect(notifyCount, 1);
    });
  });
}
