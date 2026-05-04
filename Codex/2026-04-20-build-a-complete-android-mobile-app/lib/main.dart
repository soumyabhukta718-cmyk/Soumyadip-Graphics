import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'providers/pomodoro_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/study_data_provider.dart';
import 'providers/tutor_provider.dart';
import 'screens/app_shell.dart';
import 'services/app_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final AppBootstrap bootstrap = await AppBootstrap.initialize();
  runApp(ShindhuApp(bootstrap: bootstrap));
}

class ShindhuApp extends StatelessWidget {
  const ShindhuApp({
    super.key,
    required this.bootstrap,
  });

  final AppBootstrap bootstrap;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(bootstrap.preferencesService),
        ),
        ChangeNotifierProvider<StudyDataProvider>(
          create: (_) => StudyDataProvider(
            databaseService: bootstrap.databaseService,
            plannerService: bootstrap.plannerService,
            notificationService: bootstrap.notificationService,
            preferencesService: bootstrap.preferencesService,
            motivationService: bootstrap.motivationService,
            gkService: bootstrap.gkService,
            syncService: bootstrap.syncService,
          ),
        ),
        ChangeNotifierProvider<TutorProvider>(
          create: (_) => TutorProvider(bootstrap.tutorService),
        ),
        ChangeNotifierProvider<PomodoroProvider>(
          create: (_) => PomodoroProvider(
            databaseService: bootstrap.databaseService,
            notificationService: bootstrap.notificationService,
          ),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (BuildContext context, SettingsProvider settings, Widget? child) {
          return MaterialApp(
            title: 'Shindhu - AI Study Companion',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: settings.themeMode,
            home: const AppShell(),
          );
        },
      ),
    );
  }
}
