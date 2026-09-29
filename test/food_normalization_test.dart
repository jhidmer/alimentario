import 'package:flutter_test/flutter_test.dart';

import 'package:alimentos/features/foods/data/food_repository_impl.dart';

void main() {
  group('normalizeFoodName', () {
    test('normaliza mayúsculas, acentos y espacios', () {
      expect(normalizeFoodName('  Plátano  Maduro '), 'platano maduro');
    });

    test('normaliza la ñ', () {
      expect(normalizeFoodName('Piñón'), 'pinon');
    });
  });
}
