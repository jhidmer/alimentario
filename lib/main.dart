import 'dart:async';

import 'package:flutter/material.dart';

import 'core/database/database_provider.dart';
import 'core/navigation/app_shell.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/utils/app_logger.dart';
import 'features/onboarding/presentation/onboarding_page.dart';

void main() {
  FlutterError.onError = (details) {
    AppLogger.error('Error no controlado de Flutter', details.exception, details.stack);
    FlutterError.presentError(details);
  };
  runZonedGuarded(() => runApp(const FoodDiaryApp()), (error, stackTrace) {
    AppLogger.error('Error no controlado de la aplicación', error, stackTrace);
  });
}

class FoodDiaryApp extends StatefulWidget {
  const FoodDiaryApp({this.skipOnboarding = false, super.key});

  final bool skipOnboarding;

  @override
  State<FoodDiaryApp> createState() => _FoodDiaryAppState();
}

class _FoodDiaryAppState extends State<FoodDiaryApp> {
  late final ThemeController _themeController;

  @override
  void initState() {
    super.initState();
    _themeController = ThemeController(appDatabase)..load();
  }

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diario Alimentario',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeController.mode,
      home: widget.skipOnboarding ? AppShell(themeController: _themeController) : AppStartup(themeController: _themeController),
    );
  }
}

class AppStartup extends StatefulWidget {
  const AppStartup({required this.themeController, super.key});

  final ThemeController themeController;

  @override
  State<AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends State<AppStartup> {
  late Future<bool> _firstRun;

  @override
  void initState() {
    super.initState();
    _firstRun = _isFirstRun();
  }

  Future<bool> _isFirstRun() async => (await appDatabase.settingsDao.find('first_run'))?.value != 'completed';

  Future<void> _completeOnboarding() async {
    await appDatabase.settingsDao.save('first_run', 'completed');
    if (mounted) setState(() => _firstRun = Future.value(false));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _firstRun,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        return snapshot.data!
            ? OnboardingPage(onComplete: _completeOnboarding)
            : AppShell(themeController: widget.themeController);
      },
    );
  }
}
