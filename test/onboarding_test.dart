import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:alimentos/features/onboarding/presentation/onboarding_page.dart';

void main() {
  testWidgets('completa la presentación inicial', (tester) async {
    var completed = false;
    await tester.pumpWidget(MaterialApp(onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => OnboardingPage(onComplete: () => completed = true))));

    expect(find.text('Registra tus comidas'), findsOneWidget);
    for (var index = 0; index < 3; index++) {
      await tester.tap(find.text('CONTINUAR'));
      await tester.pump();
    }
    expect(find.text('COMENZAR'), findsOneWidget);
    await tester.tap(find.text('COMENZAR'));
    expect(completed, isTrue);
  });
}
