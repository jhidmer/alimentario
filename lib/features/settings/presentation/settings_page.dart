import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:share_plus/share_plus.dart';
import 'package:restart_app/restart_app.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/theme/theme_controller.dart';
import '../../foods/presentation/food_catalog_page.dart';
import '../../backup/data/backup_repository_impl.dart';
import '../../export/data/export_repository_impl.dart';
import 'manage_options_page.dart';
import 'about_page.dart';
import 'privacy_page.dart';
import '../data/settings_repository_impl.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({required this.themeController, super.key});

  final ThemeController themeController;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final SettingsRepositoryImpl _settings;
  late final BackupRepositoryImpl _backups;
  late final ExportRepositoryImpl _exports;
  String _analysisWindow = '6';

  @override
  void initState() {
    super.initState();
    _settings = SettingsRepositoryImpl(appDatabase);
    _backups = BackupRepositoryImpl(appDatabase);
    _exports = ExportRepositoryImpl(appDatabase);
    _load();
  }

  Future<void> _load() async {
    final value = await _settings.get('analysis_window');
    if (value != null && mounted) setState(() => _analysisWindow = value);
  }

  Future<void> _saveWindow(String value) async {
    setState(() => _analysisWindow = value);
    await _settings.set('analysis_window', value);
  }

  Future<void> _createBackup() async {
    try {
      final path = await _backups.createBackup();
      if (mounted) _message('Copia creada: $path');
    } on FormatException catch (error) {
      if (mounted) _message(error.message);
    } catch (_) {
      if (mounted) _message('No se pudo crear la copia.');
    }
  }

  Future<void> _restoreBackup() async {
    final result = await openFile(acceptedTypeGroups: [const XTypeGroup(label: 'Diario Alimentario', extensions: ['diarybackup'])]);
    final path = result?.path;
    if (path == null || !mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar copia'),
        content: const Text('Se creará una copia automática del estado actual antes de restaurar.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Restaurar')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _backups.restoreBackup(path);
      if (mounted) {
        _message('Copia restaurada. Reiniciando la aplicación...');
        await Future<void>.delayed(const Duration(milliseconds: 700));
        Restart.restartApp();
      }
    } on FormatException catch (error) {
      if (mounted) _message(error.message);
    } catch (_) {
      if (mounted) _message('No se pudo restaurar la copia.');
    }
  }

  void _message(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  Future<void> _exportCsv() async {
    final range = await _chooseExportRange();
    if (range == null) return;
    try {
      final paths = (await _exports.exportCsv(from: range.start, to: range.end.add(const Duration(days: 1)))).split('\n');
      await Share.shareXFiles(paths.map((value) => XFile(value)).toList(), text: 'Exportación CSV de Diario Alimentario');
    } catch (_) {
      _message('No se pudo exportar el CSV.');
    }
  }

  Future<void> _exportPdf() async {
    final range = await _chooseExportRange();
    if (range == null) return;
    try {
      final filePath = await _exports.generatePdf(from: range.start, to: range.end.add(const Duration(days: 1)));
      await Share.shareXFiles([XFile(filePath)], text: 'Informe de Diario Alimentario');
    } catch (_) {
      _message('No se pudo generar el PDF.');
    }
  }

  Future<DateTimeRange?> _chooseExportRange() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
            for (final item in const {'7': 'Últimos 7 días', '15': 'Últimos 15 días', '30': 'Últimos 30 días', '90': 'Últimos 90 días', 'custom': 'Personalizado'}.entries)
              ListTile(title: Text(item.value), onTap: () => Navigator.pop(context, item.key)),
          ])),
    );
    if (choice == null || !mounted) return null;
    final now = DateTime.now();
    if (choice == 'custom') {
      return showDateRangePicker(context: context, firstDate: DateTime(2020), lastDate: now, currentDate: now, initialDateRange: DateTimeRange(start: now.subtract(const Duration(days: 30)), end: now));
    }
    final days = int.parse(choice);
    return DateTimeRange(start: now.subtract(Duration(days: days - 1)), end: now);
  }

  Future<void> _deleteAllData() async {
    final first = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar todos los datos'),
        content: const Text('Se eliminarán comidas, alimentos, reacciones y fotografías. Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Continuar')),
        ],
      ),
    );
    if (first != true || !mounted) return;
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmación final'),
        content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(labelText: 'Escribe BORRAR')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim().toUpperCase() == 'BORRAR'), child: const Text('Eliminar definitivamente')),
        ],
      ),
    );
    controller.dispose();
    if (confirmed != true) return;
    await appDatabase.deleteAllUserData();
    if (mounted) _message('Todos los datos fueron eliminados.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        children: [
          const _SectionTitle('Datos'),
          ListTile(
            leading: const Icon(Icons.restaurant_menu),
            title: const Text('Alimentos y categorías'),
            subtitle: const Text('Administra tu catálogo personal'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FoodCatalogPage())),
          ),
          ListTile(
            leading: const Icon(Icons.file_upload_outlined),
            title: const Text('Crear copia de seguridad'),
            subtitle: const Text('Guarda la base de datos y fotografías localmente'),
            onTap: _createBackup,
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Restaurar copia'),
            subtitle: const Text('Reemplaza los datos actuales'),
            onTap: _restoreBackup,
          ),
          ListTile(
            leading: const Icon(Icons.table_view),
            title: const Text('Exportar CSV'),
            subtitle: const Text('Comidas, reacciones y alimentos'),
            onTap: _exportCsv,
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: const Text('Generar informe PDF'),
            subtitle: const Text('Resumen de los registros locales'),
            onTap: _exportPdf,
          ),
          const _SectionTitle('Análisis'),
          ListTile(
            leading: const Icon(Icons.tune),
            title: const Text('Gestionar categorías y síntomas'),
            subtitle: const Text('Crea opciones personalizadas'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ManageOptionsPage())),
          ),
          const _SectionTitle('Apariencia'),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Tema'),
            trailing: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode), label: Text('Claro')),
                ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode), label: Text('Oscuro')),
              ],
              selected: {widget.themeController.mode},
              onSelectionChanged: (value) => widget.themeController.setMode(value.first),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.tune),
            title: const Text('Ventana predeterminada'),
            subtitle: const Text('Se usará para asociaciones temporales'),
            trailing: DropdownButton<String>(
              value: _analysisWindow,
              items: const [
                DropdownMenuItem(value: '2', child: Text('2 h')),
                DropdownMenuItem(value: '4', child: Text('4 h')),
                DropdownMenuItem(value: '6', child: Text('6 h')),
                DropdownMenuItem(value: '12', child: Text('12 h')),
                DropdownMenuItem(value: '24', child: Text('24 h')),
              ],
              onChanged: (value) {
                if (value != null) _saveWindow(value);
              },
            ),
          ),
          const _SectionTitle('Privacidad'),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Política de privacidad'),
            subtitle: const Text('Datos locales y uso de fotografías'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PrivacyPage())),
          ),
          const ListTile(
            leading: Icon(Icons.lock_outline),
            title: Text('Datos almacenados localmente'),
            subtitle: Text('La aplicación no envía información a servidores externos.'),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Información del desarrollador'),
            subtitle: const Text('Contacto y apoyo al proyecto'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AboutPage())),
          ),
          const _SectionTitle('Borrar datos'),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Eliminar todos los datos'),
            subtitle: const Text('Requiere doble confirmación'),
            onTap: _deleteAllData,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
        child: Text(title.toUpperCase(), style: Theme.of(context).textTheme.labelMedium),
      );
}
