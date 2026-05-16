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
        productName: 'Fertilitzant',
        amount: 4,
        imageUrl: 'https://example.com/fertilitzant.png',
      );

      expect(product.productName, 'Fertilitzant');
      expect(product.amount, 4);
      expect(product.imageUrl, 'https://example.com/fertilitzant.png');
    });

    test('constructor accepta imageUrl null', () {
      final product = ProductItem(
        productName: 'Poció de creixement',
        amount: 1,
      );

      expect(product.productName, 'Poció de creixement');
      expect(product.amount, 1);
      expect(product.imageUrl, isNull);
    });

    test('fromJson converteix correctament el JSON amb imatge', () {
      final product = ProductItem.fromJson({
        'productName': 'Regadora',
        'amount': 3,
        'image_url': 'https://example.com/regadora.png',
      });

      expect(product.productName, 'Regadora');
      expect(product.amount, 3);
      expect(product.imageUrl, 'https://example.com/regadora.png');
    });

    test('fromJson converteix correctament el JSON sense imatge', () {
      final product = ProductItem.fromJson({
        'productName': 'Adob',
        'amount': 6,
        'image_url': null,
      });

      expect(product.productName, 'Adob');
      expect(product.amount, 6);
      expect(product.imageUrl, isNull);
    });
  });
}
