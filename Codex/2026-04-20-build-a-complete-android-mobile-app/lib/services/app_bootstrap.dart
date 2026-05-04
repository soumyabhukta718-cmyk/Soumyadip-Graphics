import 'database_service.dart';
import 'gk_service.dart';
import 'motivation_service.dart';
import 'notification_service.dart';
import 'offline_ai_service.dart';
import 'online_ai_service.dart';
import 'planner_service.dart';
import 'preferences_service.dart';
import 'sync_service.dart';
import 'tts_service.dart';
import 'tutor_service.dart';

class AppBootstrap {
  AppBootstrap({
    required this.databaseService,
    required this.preferencesService,
    required this.notificationService,
    required this.tutorService,
    required this.plannerService,
    required this.motivationService,
    required this.gkService,
    required this.syncService,
  });

  final DatabaseService databaseService;
  final PreferencesService preferencesService;
  final NotificationService notificationService;
  final TutorService tutorService;
  final PlannerService plannerService;
  final MotivationService motivationService;
  final GkService gkService;
  final SyncService syncService;

  static Future<AppBootstrap> initialize() async {
    final PreferencesService preferencesService = await PreferencesService.create();
    final DatabaseService databaseService = DatabaseService();
    await databaseService.initialize();

    final NotificationService notificationService = NotificationService();
    await notificationService.initialize();

    final TtsService ttsService = TtsService();
    await ttsService.initialize();

    final TutorService tutorService = TutorService(
      databaseService: databaseService,
      offlineAiService: OfflineAiService(),
      onlineAiService: OnlineAiService(),
      ttsService: ttsService,
    );

    return AppBootstrap(
      databaseService: databaseService,
      preferencesService: preferencesService,
      notificationService: notificationService,
      tutorService: tutorService,
      plannerService: PlannerService(),
      motivationService: MotivationService(),
      gkService: GkService(),
      syncService: SyncService(),
    );
  }
}
