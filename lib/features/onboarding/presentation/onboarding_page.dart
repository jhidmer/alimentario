import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({required this.onComplete, super.key});

  final VoidCallback onComplete;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _page = 0;

  static const _steps = [
    (Icons.restaurant, 'Registra tus comidas', 'Anota qué comiste y a qué hora.'),
    (Icons.monitor_heart_outlined, 'Registra cualquier reacción', 'Guarda síntomas, intensidad y duración.'),
    (Icons.calendar_month, 'Consulta tu historial', 'Revisa tus registros por día y calendario.'),
    (Icons.insights, 'Descubre patrones', 'Observa asociaciones temporales sin asumir causalidad.'),
  ];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_page];
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(children: [
            const Spacer(),
            Icon(step.$1, size: 88, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 28),
            Text(step.$2, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(step.$3, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
            const Spacer(),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(_steps.length, (index) => Container(
                  width: index == _page ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(color: index == _page ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant, borderRadius: BorderRadius.circular(8)),
                ))),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (_page == _steps.length - 1) {
                    widget.onComplete();
                  } else {
                    setState(() => _page++);
                  }
                },
                child: Text(_page == _steps.length - 1 ? 'COMENZAR' : 'CONTINUAR'),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
