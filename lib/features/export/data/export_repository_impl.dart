import 'dart:io';

import 'package:pdf/widgets.dart' as pw;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../../core/database/app_database.dart';

class ExportRepositoryImpl {
  ExportRepositoryImpl(this._database);

  final AppDatabase _database;

  Future<String> exportCsv({required DateTime from, required DateTime to}) async {
    final directory = await _exportDirectory();
    final meals = await _database.mealDao.between(from, to);
    final reactions = await _database.reactionDao.between(from, to);
    final foods = await _database.foodDao.frequent();
    final mealRows = <List<String>>[
      ['id', 'fecha_hora', 'tipo', 'alimentos', 'observaciones'],
    ];
    for (final meal in meals) {
      final names = <String>[];
      for (final link in await _database.mealDao.foodsForMeal(meal.id)) {
        final food = await _database.foodDao.findById(link.foodId);
        if (food != null) names.add(food.name);
      }
      mealRows.add(['${meal.id}', meal.mealDatetime.toIso8601String(), meal.mealType, names.join(' | '), meal.notes ?? '']);
    }
    final reactionRows = <List<String>>[
      ['id', 'inicio', 'fin', 'intensidad', 'zona', 'estado', 'observaciones'],
      ...reactions.map((reaction) => ['${reaction.id}', reaction.startedAt.toIso8601String(), reaction.endedAt?.toIso8601String() ?? '', '${reaction.intensity}', reaction.bodyArea ?? '', reaction.status, reaction.notes ?? '']),
    ];
    final foodRows = <List<String>>[
      ['id', 'nombre', 'usos', 'ultimo_uso'],
      ...foods.map((food) => ['${food.id}', food.name, '${food.usageCount}', food.lastUsedAt?.toIso8601String() ?? '']),
    ];
    final paths = <String>[];
    for (final entry in {'meals.csv': mealRows, 'reactions.csv': reactionRows, 'foods.csv': foodRows}.entries) {
      final file = File(path.join(directory.path, entry.key));
      await file.writeAsString(entry.value.map((row) => row.map(_csv).join(',')).join('\n'), flush: true);
      paths.add(file.path);
    }
    return paths.join('\n');
  }

  Future<String> generatePdf({required DateTime from, required DateTime to}) async {
    final directory = await _exportDirectory();
    final meals = await _database.mealDao.between(from, to);
    final reactions = await _database.reactionDao.between(from, to);
    final document = pw.Document();
    document.addPage(pw.MultiPage(build: (context) => [
          pw.Header(level: 0, text: 'Diario Alimentario'),
          pw.Text('Informe generado: ${DateTime.now().toLocal()}'),
          pw.SizedBox(height: 20),
          pw.Text('Resumen', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Bullet(text: 'Comidas registradas: ${meals.length}'),
          pw.Bullet(text: 'Reacciones registradas: ${reactions.length}'),
          pw.SizedBox(height: 20),
          pw.Text('Este informe muestra registros personales y no constituye un diagnóstico médico.'),
        ]));
    final file = File(path.join(directory.path, 'diario_${DateTime.now().millisecondsSinceEpoch}.pdf'));
    await file.writeAsBytes(await document.save(), flush: true);
    return file.path;
  }

  Future<Directory> _exportDirectory() async {
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory(path.join(root.path, 'exports'));
    await directory.create(recursive: true);
    return directory;
  }

  String _csv(String value) => '"${value.replaceAll('"', '""')}"';
}
