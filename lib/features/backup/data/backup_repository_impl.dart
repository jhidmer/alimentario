import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../../core/database/app_database.dart';
import '../domain/backup_repository.dart';

class BackupRepositoryImpl implements BackupRepository {
  BackupRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Future<String> createBackup({String? destinationDirectory}) async {
    final databaseFile = File(await _database.filePath());
    if (!await databaseFile.exists()) throw const FormatException('La base de datos no existe.');
    final archive = Archive();
    final databaseBytes = await databaseFile.readAsBytes();
    archive.addFile(ArchiveFile('database.sqlite', databaseBytes.length, databaseBytes));
    final photosDirectory = Directory(path.join(databaseFile.parent.path, 'reaction_photos'));
    if (await photosDirectory.exists()) {
      await for (final entity in photosDirectory.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          final bytes = await entity.readAsBytes();
          archive.addFile(ArchiveFile(path.join('photos', path.basename(entity.path)), bytes.length, bytes));
        }
      }
    }
    final metadata = utf8.encode(jsonEncode({'format': 'diarybackup', 'version': 1, 'created_at': DateTime.now().toIso8601String()}));
    archive.addFile(ArchiveFile('metadata.json', metadata.length, metadata));
    final encoded = ZipEncoder().encode(archive);
    final directory = await getApplicationDocumentsDirectory();
    final backupDirectory = Directory(destinationDirectory ?? path.join(directory.path, 'backups'));
    await backupDirectory.create(recursive: true);
    final file = File(path.join(backupDirectory.path, 'diario_${_stamp(DateTime.now())}.diarybackup'));
    await file.writeAsBytes(encoded, flush: true);
    return file.path;
  }

  @override
  Future<void> restoreBackup(String filePath) async {
    final source = File(filePath);
    if (!await source.exists()) throw const FormatException('No se encontró la copia.');
    final archive = ZipDecoder().decodeBytes(await source.readAsBytes());
    final metadataFile = archive.findFile('metadata.json');
    final databaseEntry = archive.findFile('database.sqlite');
    if (metadataFile == null || databaseEntry == null) throw const FormatException('La copia no es válida.');
    final metadata = jsonDecode(utf8.decode(metadataFile.content as List<int>)) as Map<String, dynamic>;
    if (metadata['format'] != 'diarybackup' || metadata['version'] != 1) throw const FormatException('Versión de copia no compatible.');
    await createBackup();
    await _database.close();
    final current = File(await _database.filePath());
    await current.writeAsBytes(databaseEntry.content as List<int>, flush: true);
    final directory = current.parent;
    final photosDirectory = Directory(path.join(directory.path, 'reaction_photos'));
    await photosDirectory.create(recursive: true);
    for (final entry in archive.files.where((file) => file.name.startsWith('photos/'))) {
      final destination = File(path.join(photosDirectory.path, path.basename(entry.name)));
      await destination.writeAsBytes(entry.content as List<int>, flush: true);
    }
  }

  String _stamp(DateTime date) => '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}_${date.hour.toString().padLeft(2, '0')}${date.minute.toString().padLeft(2, '0')}';
}
