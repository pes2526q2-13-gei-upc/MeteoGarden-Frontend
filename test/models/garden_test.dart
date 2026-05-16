import 'package:flutter_test/flutter_test.dart';
import 'package:meteo_garden/models/garden.dart';

void main() {
  group('ActivePotion', () {
    test('constructor assigna correctament els camps', () {
      final appliedAt = DateTime(2026, 5, 16, 10);
      final expiresAt = DateTime(2026, 5, 17, 10);

      final potion = ActivePotion(
        name: 'Fertilitzant',
        appliedAt: appliedAt,
        expiresAt: expiresAt,
      );

      expect(potion.name, 'Fertilitzant');
      expect(potion.appliedAt, appliedAt);
      expect(potion.expiresAt, expiresAt);
    });

    test('isActive retorna true si encara no ha expirat', () {
      final potion = ActivePotion(
        name: 'Poció activa',
        appliedAt: DateTime.now().subtract(const Duration(hours: 1)),
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      expect(potion.isActive, isTrue);
    });

    test('isActive retorna false si ja ha expirat', () {
      final potion = ActivePotion(
        name: 'Poció expirada',
        appliedAt: DateTime.now().subtract(const Duration(hours: 2)),
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
      );

      expect(potion.isActive, isFalse);
    });

    test('fromJson converteix correctament el JSON', () {
      final potion = ActivePotion.fromJson({
        'name': 'Fertilitzant',
        'applied_at': '2026-05-16T10:00:00',
        'expires_at': '2026-05-17T10:00:00',
      });

      expect(potion.name, 'Fertilitzant');
      expect(potion.appliedAt, DateTime.parse('2026-05-16T10:00:00'));
      expect(potion.expiresAt, DateTime.parse('2026-05-17T10:00:00'));
    });
  });

  group('PlantData', () {
    test('constructor assigna correctament tots els camps', () {
      final plant = PlantData(
        scientificName: 'Rosa rubiginosa',
        commonName: 'Rosa',
        family: 'Rosaceae',
        canFlower: true,
        minTemperature: 5.0,
        maxTemperature: 30.0,
        imageUrl: 'https://example.com/rosa.png',
      );

      expect(plant.scientificName, 'Rosa rubiginosa');
      expect(plant.commonName, 'Rosa');
      expect(plant.family, 'Rosaceae');
      expect(plant.canFlower, isTrue);
      expect(plant.minTemperature, 5.0);
      expect(plant.maxTemperature, 30.0);
      expect(plant.imageUrl, 'https://example.com/rosa.png');
    });

    test('fromJson converteix correctament el JSON', () {
      final plant = PlantData.fromJson({
        'scientific_name': 'Mentha spicata',
        'common_name': 'Menta',
        'family': 'Lamiaceae',
        'can_flower': true,
        'min_temperature': 8,
        'max_temperature': 28.5,
        'image_url': 'https://example.com/menta.png',
      });

      expect(plant.scientificName, 'Mentha spicata');
      expect(plant.commonName, 'Menta');
      expect(plant.family, 'Lamiaceae');
      expect(plant.canFlower, isTrue);
      expect(plant.minTemperature, 8.0);
      expect(plant.maxTemperature, 28.5);
      expect(plant.imageUrl, 'https://example.com/menta.png');
    });

    test('fromJson accepta image_url null', () {
      final plant = PlantData.fromJson({
        'scientific_name': 'Lavandula angustifolia',
        'common_name': 'Lavanda',
        'family': 'Lamiaceae',
        'can_flower': true,
        'min_temperature': 4,
        'max_temperature': 32,
        'image_url': null,
      });

      expect(plant.scientificName, 'Lavandula angustifolia');
      expect(plant.commonName, 'Lavanda');
      expect(plant.family, 'Lamiaceae');
      expect(plant.canFlower, isTrue);
      expect(plant.minTemperature, 4.0);
      expect(plant.maxTemperature, 32.0);
      expect(plant.imageUrl, isNull);
    });
  });

  group('GardenPot', () {
    test('constructor assigna correctament els camps amb planta', () {
      final plantedAt = DateTime(2026, 5, 10);
      final lastWateredAt = DateTime(2026, 5, 15);

      final plant = PlantData(
        scientificName: 'Mentha spicata',
        commonName: 'Menta',
        family: 'Lamiaceae',
        canFlower: true,
        minTemperature: 8.0,
        maxTemperature: 28.0,
        imageUrl: null,
      );

      final pot = GardenPot(
        potNumber: 1,
        occupied: true,
        plant: plant,
        growthPhase: 'Growing',
        healthLevel: 85.0,
        waterLevel: 60.0,
        plantedAt: plantedAt,
        lastWateredAt: lastWateredAt,
      );

      expect(pot.potNumber, 1);
      expect(pot.occupied, isTrue);
      expect(pot.plant, plant);
      expect(pot.growthPhase, 'Growing');
      expect(pot.healthLevel, 85.0);
      expect(pot.waterLevel, 60.0);
      expect(pot.plantedAt, plantedAt);
      expect(pot.lastWateredAt, lastWateredAt);
      expect(pot.activeProducts, isEmpty);
      expect(pot.hasBuff, isFalse);
    });

    test('constructor assigna correctament els camps sense planta', () {
      final pot = GardenPot(
        potNumber: 2,
        occupied: false,
        plant: null,
        growthPhase: null,
        healthLevel: null,
        waterLevel: null,
        plantedAt: null,
        lastWateredAt: null,
      );

      expect(pot.potNumber, 2);
      expect(pot.occupied, isFalse);
      expect(pot.plant, isNull);
      expect(pot.growthPhase, isNull);
      expect(pot.healthLevel, isNull);
      expect(pot.waterLevel, isNull);
      expect(pot.plantedAt, isNull);
      expect(pot.lastWateredAt, isNull);
      expect(pot.activeProducts, isEmpty);
      expect(pot.hasBuff, isFalse);
    });

    test('hasBuff retorna true si hi ha una poció activa', () {
      final pot = GardenPot(
        potNumber: 1,
        occupied: true,
        plant: null,
        growthPhase: null,
        healthLevel: null,
        waterLevel: null,
        plantedAt: null,
        lastWateredAt: null,
        activeProducts: [
          ActivePotion(
            name: 'Fertilitzant',
            appliedAt: DateTime.now().subtract(const Duration(hours: 1)),
            expiresAt: DateTime.now().add(const Duration(hours: 1)),
          ),
        ],
      );

      expect(pot.hasBuff, isTrue);
    });

    test('hasBuff retorna false si totes les pocions han expirat', () {
      final pot = GardenPot(
        potNumber: 1,
        occupied: true,
        plant: null,
        growthPhase: null,
        healthLevel: null,
        waterLevel: null,
        plantedAt: null,
        lastWateredAt: null,
        activeProducts: [
          ActivePotion(
            name: 'Fertilitzant',
            appliedAt: DateTime.now().subtract(const Duration(hours: 3)),
            expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
        ],
      );

      expect(pot.hasBuff, isFalse);
    });

    test('fromJson converteix correctament un test ocupat amb planta', () {
      final pot = GardenPot.fromJson({
        'pot_number': 1,
        'occupied': true,
        'growth_phase': 'Adult',
        'health_level': 90,
        'water_level': 75.5,
        'planted_at': '2026-05-10T09:00:00',
        'last_watered_at': '2026-05-15T12:30:00',
        'plant': {
          'scientific_name': 'Mentha spicata',
          'common_name': 'Menta',
          'family': 'Lamiaceae',
          'can_flower': true,
          'min_temperature': 8,
          'max_temperature': 28.5,
          'image_url': 'https://example.com/menta.png',
          'active_products': [
            {
              'name': 'Poció activa',
              'applied_at': DateTime.now()
                  .subtract(const Duration(hours: 1))
                  .toIso8601String(),
              'expires_at': DateTime.now()
                  .add(const Duration(hours: 1))
                  .toIso8601String(),
            },
          ],
        },
      });

      expect(pot.potNumber, 1);
      expect(pot.occupied, isTrue);
      expect(pot.growthPhase, 'Adult');
      expect(pot.healthLevel, 90.0);
      expect(pot.waterLevel, 75.5);
      expect(pot.plantedAt, DateTime.parse('2026-05-10T09:00:00'));
      expect(pot.lastWateredAt, DateTime.parse('2026-05-15T12:30:00'));

      expect(pot.plant, isNotNull);
      expect(pot.plant!.scientificName, 'Mentha spicata');
      expect(pot.plant!.commonName, 'Menta');
      expect(pot.plant!.family, 'Lamiaceae');
      expect(pot.plant!.canFlower, isTrue);
      expect(pot.plant!.minTemperature, 8.0);
      expect(pot.plant!.maxTemperature, 28.5);
      expect(pot.plant!.imageUrl, 'https://example.com/menta.png');

      expect(pot.activeProducts.length, 1);
      expect(pot.activeProducts.first.name, 'Poció activa');
      expect(pot.hasBuff, isTrue);
    });

    test('fromJson converteix correctament un test buit', () {
      final pot = GardenPot.fromJson({
        'pot_number': 3,
        'occupied': false,
        'growth_phase': null,
        'health_level': null,
        'water_level': null,
        'planted_at': null,
        'last_watered_at': null,
        'plant': null,
      });

      expect(pot.potNumber, 3);
      expect(pot.occupied, isFalse);
      expect(pot.plant, isNull);
      expect(pot.growthPhase, isNull);
      expect(pot.healthLevel, isNull);
      expect(pot.waterLevel, isNull);
      expect(pot.plantedAt, isNull);
      expect(pot.lastWateredAt, isNull);
      expect(pot.activeProducts, isEmpty);
      expect(pot.hasBuff, isFalse);
    });

    test('fromJson filtra les pocions expirades', () {
      final pot = GardenPot.fromJson({
        'pot_number': 1,
        'occupied': true,
        'growth_phase': 'Growing',
        'health_level': 80,
        'water_level': 70,
        'planted_at': '2026-05-10T09:00:00',
        'last_watered_at': '2026-05-15T12:30:00',
        'plant': {
          'scientific_name': 'Mentha spicata',
          'common_name': 'Menta',
          'family': 'Lamiaceae',
          'can_flower': true,
          'min_temperature': 8,
          'max_temperature': 28,
          'image_url': null,
          'active_products': [
            {
              'name': 'Poció activa',
              'applied_at': DateTime.now()
                  .subtract(const Duration(hours: 1))
                  .toIso8601String(),
              'expires_at': DateTime.now()
                  .add(const Duration(hours: 1))
                  .toIso8601String(),
            },
            {
              'name': 'Poció expirada',
              'applied_at': DateTime.now()
                  .subtract(const Duration(hours: 3))
                  .toIso8601String(),
              'expires_at': DateTime.now()
                  .subtract(const Duration(hours: 1))
                  .toIso8601String(),
            },
          ],
        },
      });

      expect(pot.activeProducts.length, 1);
      expect(pot.activeProducts.first.name, 'Poció activa');
      expect(pot.hasBuff, isTrue);
    });

    test(
      'fromJson deixa activeProducts buit si la planta no té active_products',
      () {
        final pot = GardenPot.fromJson({
          'pot_number': 1,
          'occupied': true,
          'growth_phase': 'Growing',
          'health_level': 80,
          'water_level': 70,
          'planted_at': '2026-05-10T09:00:00',
          'last_watered_at': '2026-05-15T12:30:00',
          'plant': {
            'scientific_name': 'Mentha spicata',
            'common_name': 'Menta',
            'family': 'Lamiaceae',
            'can_flower': true,
            'min_temperature': 8,
            'max_temperature': 28,
            'image_url': null,
          },
        });

        expect(pot.activeProducts, isEmpty);
        expect(pot.hasBuff, isFalse);
      },
    );
  });
}
