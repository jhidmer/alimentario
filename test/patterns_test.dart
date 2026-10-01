import 'package:flutter_test/flutter_test.dart';

import 'package:alimentos/features/patterns/domain/pattern_repository.dart';

void main() {
  test('calcula el porcentaje de asociación temporal', () {
    const result = PatternResult(
      foodName: 'Queso',
      total: 15,
      withReaction: 9,
      withoutReaction: 6,
      symptoms: {},
    );

    expect(result.percentage, 60);
  });

  test('una ventana de patrón conserva las horas configuradas', () {
    const window = PatternWindow(hours: 6);
    expect(window.hours, 6);
  });

  test('clasifica la confianza según el tamaño de muestra', () {
    const low = PatternResult(foodName: 'Pan', total: 3, withReaction: 1, withoutReaction: 2, symptoms: {});
    const moderate = PatternResult(foodName: 'Arroz', total: 12, withReaction: 4, withoutReaction: 8, symptoms: {});
    expect(low.confidenceLabel, 'Datos insuficientes');
    expect(low.hasMinimumSample, isFalse);
    expect(moderate.confidenceLabel, 'Confianza moderada');
    expect(moderate.hasMinimumSample, isTrue);
  });
}
