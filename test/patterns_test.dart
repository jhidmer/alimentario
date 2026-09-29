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
}
