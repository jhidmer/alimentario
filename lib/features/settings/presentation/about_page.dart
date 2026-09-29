import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acerca de la aplicación')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
        children: [
          Center(
            child: Icon(Icons.restaurant_menu, size: 72, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 16),
          Text('Diario Alimentario', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text('Versión 0.1.0', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Desarrollador', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 14),
                const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.person_outline), title: Text('Jhidmer Manrique Jorge')),
                const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.email_outlined), title: Text('jhidmer@gmail.com')),
                const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.phone_outlined), title: Text('992726854')),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.favorite_outline, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 12),
                Text('Apoya el proyecto', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                const Text('Tu apoyo económico ayuda a mantener y seguir mejorando Diario Alimentario, incorporar nuevas funciones y ofrecer una mejor experiencia.'),
              ]),
            ),
          ),
          const SizedBox(height: 20),
          Text('La información registrada permanece en este dispositivo y la aplicación no realiza diagnósticos médicos.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
