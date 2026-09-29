import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacidad')), 
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text('Política de privacidad', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('Última actualización: 29 de septiembre de 2026.'),
          const SizedBox(height: 20),
          const _PrivacySection(title: 'Almacenamiento local', body: 'Diario Alimentario guarda comidas, alimentos, reacciones, síntomas y fotografías únicamente en el almacenamiento privado de este dispositivo. La aplicación no requiere una cuenta ni envía estos datos a servidores externos.'),
          const _PrivacySection(title: 'Fotografías', body: 'Las fotografías son opcionales. Cuando se agregan, se almacenan en el almacenamiento privado de la aplicación y se registra únicamente su ruta local en la base de datos.'),
          const _PrivacySection(title: 'Uso de la información', body: 'Los datos se utilizan para mostrar el historial, calcular estadísticas y encontrar asociaciones temporales dentro de los registros del usuario. No se venden, publicitan ni comparten con terceros.'),
          const _PrivacySection(title: 'Cámara y archivos', body: 'La cámara y el selector de imágenes solo se utilizan cuando el usuario solicita agregar una fotografía a una reacción. El permiso puede rechazarse y la función principal seguirá disponible.'),
          const _PrivacySection(title: 'Eliminación', body: 'El usuario puede eliminar comidas, reacciones, fotografías y todos los datos desde Configuración. La eliminación total requiere una doble confirmación.'),
          const _PrivacySection(title: 'Salud y limitaciones', body: 'La aplicación no es un dispositivo médico y no diagnostica, trata, cura ni previene ninguna enfermedad. Las asociaciones mostradas son coincidencias estadísticas y no demuestran causalidad. Para orientación médica se debe consultar a un profesional de la salud.'),
          const _PrivacySection(title: 'Contacto', body: 'Jhidmer Manrique Jorge\njhidmer@gmail.com\n992726854'),
        ],
      ),
    );
  }
}

class _PrivacySection extends StatelessWidget {
  const _PrivacySection({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(body),
        ]),
      );
}
