import 'package:flutter_test/flutter_test.dart';

import 'package:alimentos/main.dart';

void main() {
  testWidgets('muestra la navegación principal', (WidgetTester tester) async {
    await tester.pumpWidget(const FoodDiaryApp(skipOnboarding: true));
    await tester.pump();

    expect(find.text('Hoy'), findsOneWidget);
    expect(find.text('Historial'), findsOneWidget);
    expect(find.text('Estadísticas'), findsOneWidget);
    expect(find.text('Configuración'), findsOneWidget);
  });
}
