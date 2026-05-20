import 'package:flutter_test/flutter_test.dart';
import 'package:meteo_garden/models/seed_option.dart';

void main() {
  group('SeedOption', () {
    test('constructor assigna correctament tots els camps', () {
      const seed = SeedOption(
        scientificName: 'Mentha spicata',
        amount: 5,
        imageUrl: 'https://example.com/menta.png',
      );

      expect(seed.scientificName, 'Mentha spicata');
      expect(seed.amount, 5);
      expect(seed.imageUrl, 'https://example.com/menta.png');
    });

    test('constructor accepta imageUrl null', () {
      const seed = SeedOption(
        scientificName: 'Lavandula angustifolia',
        amount: 3,
      );

      expect(seed.scientificName, 'Lavandula angustifolia');
      expect(seed.amount, 3);
      expect(seed.imageUrl, isNull);
    });

    test('fromJson converteix correctament el JSON amb imatge', () {
      final seed = SeedOption.fromJson({
        'scientificName': 'Rosa rubiginosa',
        'amount': 7,
        'image_url': 'https://example.com/rosa.png',
      });

      expect(seed.scientificName, 'Rosa rubiginosa');
      expect(seed.amount, 7);
      expect(seed.imageUrl, 'https://example.com/rosa.png');
    });

    test('fromJson converteix correctament el JSON sense imatge', () {
      final seed = SeedOption.fromJson({
        'scientificName': 'Ocimum basilicum',
        'amount': 2,
        'image_url': null,
      });

      expect(seed.scientificName, 'Ocimum basilicum');
      expect(seed.amount, 2);
      expect(seed.imageUrl, isNull);
    });
  });

  group('ProductItem', () {
    test('constructor assigna correctament tots els camps', () {
      final product = ProductItem(
        productName: 'fertilizer',
        displayName: 'Fertilitzant',
        amount: 4,
        imageUrl: 'https://example.com/fertilitzant.png',
        description: 'Ajuda al creixement de la planta.',
      );

      expect(product.productName, 'fertilizer');
      expect(product.displayName, 'Fertilitzant');
      expect(product.amount, 4);
      expect(product.imageUrl, 'https://example.com/fertilitzant.png');
      expect(product.description, 'Ajuda al creixement de la planta.');
    });

    test('constructor accepta imageUrl i description null', () {
      final product = ProductItem(
        productName: 'growth_potion',
        displayName: 'Poció de creixement',
        amount: 1,
      );

      expect(product.productName, 'growth_potion');
      expect(product.displayName, 'Poció de creixement');
      expect(product.amount, 1);
      expect(product.imageUrl, isNull);
      expect(product.description, isNull);
    });

    test('fromJson converteix correctament el JSON amb productName i displayName', () {
      final product = ProductItem.fromJson({
        'productName': 'watering_can',
        'displayName': 'Regadora',
        'amount': 3,
        'image_url': 'https://example.com/regadora.png',
        'description': 'Serveix per regar les plantes.',
      });

      expect(product.productName, 'watering_can');
      expect(product.displayName, 'Regadora');
      expect(product.amount, 3);
      expect(product.imageUrl, 'https://example.com/regadora.png');
      expect(product.description, 'Serveix per regar les plantes.');
    });

    test('fromJson accepta product_name i display_name del backend', () {
      final product = ProductItem.fromJson({
        'product_name': 'fertilizer',
        'display_name': 'Fertilitzant',
        'amount': 6,
        'image_url': null,
        'description': null,
      });

      expect(product.productName, 'fertilizer');
      expect(product.displayName, 'Fertilitzant');
      expect(product.amount, 6);
      expect(product.imageUrl, isNull);
      expect(product.description, isNull);
    });

    test('fromJson accepta name com a nom intern', () {
      final product = ProductItem.fromJson({
        'name': 'medium_heal',
        'display_name': 'Curació mitjana',
        'amount': 2,
        'image_url': 'https://example.com/medium_heal.png',
        'description': 'Restaura una quantitat moderada de salut.',
      });

      expect(product.productName, 'medium_heal');
      expect(product.displayName, 'Curació mitjana');
      expect(product.amount, 2);
      expect(product.imageUrl, 'https://example.com/medium_heal.png');
      expect(product.description, 'Restaura una quantitat moderada de salut.');
    });

    test('fromJson usa productName com a displayName si no arriba displayName', () {
      final product = ProductItem.fromJson({
        'productName': 'Adob',
        'amount': 6,
        'image_url': null,
      });

      expect(product.productName, 'Adob');
      expect(product.displayName, 'Adob');
      expect(product.amount, 6);
      expect(product.imageUrl, isNull);
      expect(product.description, isNull);
    });

    test('fromJson posa amount a 0 si no arriba amount', () {
      final product = ProductItem.fromJson({
        'productName': 'hydration_shield',
        'displayName': 'Escut hidratant',
        'image_url': null,
      });

      expect(product.productName, 'hydration_shield');
      expect(product.displayName, 'Escut hidratant');
      expect(product.amount, 0);
      expect(product.imageUrl, isNull);
      expect(product.description, isNull);
    });
  });
}