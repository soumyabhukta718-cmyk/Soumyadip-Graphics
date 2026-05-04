import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../core/utils/date_time_utils.dart';
import '../models/chat_message.dart';
import '../models/gk_item.dart';
import '../models/goal.dart';
import '../models/motivation_item.dart';
import '../models/routine_task.dart';
import '../models/study_note.dart';
import '../services/database_service.dart';
import '../services/gk_service.dart';
import '../services/motivation_service.dart';
import '../services/notification_service.dart';
import '../services/planner_service.dart';
import '../services/preferences_service.dart';
import '../services/sync_service.dart';

class StudyDataProvider extends ChangeNotifier {
  StudyDataProvider({
    required this.databaseService,
    required this.plannerService,
    required this.notificationService,
    required this.preferencesService,
    required this.motivationService,
    required this.gkService,
    required this.syncService,
  }) {
    unawaited(initialize());
  }

  final DatabaseService databaseService;
  final PlannerService plannerService;
  final NotificationService notificationService;
  final PreferencesService preferencesService;
  final MotivationService motivationService;
  final GkService gkService;
  final SyncService syncService;

  List<RoutineTask> _routines = <RoutineTask>[];
  List<Goal> _goals = <Goal>[];
  List<StudyNote> _notes = <StudyNote>[];
  MotivationItem _motivation = const MotivationItem(
    english: 'Loading...',
    bengali: 'লোড হচ্ছে...',
    tip: 'Prepare your next study block.',
  );
  List<GkItem> _gkFeed = <GkItem>[];
  String _syncStatus = 'Preparing local database...';
  int _streak = 1;
  bool _isLoading = true;

  bool get isLoading => _isLoading;
  List<RoutineTask> get routines => List<RoutineTask>.unmodifiable(_routines);
  List<Goal> get goals => List<Goal>.unmodifiable(_goals);
  List<StudyNote> get notes => List<StudyNote>.unmodifiable(_notes);
  MotivationItem get motivation => _motivation;
  List<GkItem> get gkFeed => List<GkItem>.unmodifiable(_gkFeed);
  String get syncStatus => _syncStatus;
  int get streak => _streak;

  List<RoutineTask> get todayRoutines {
    final DateTime today = DateTimeUtils.dayOnly(DateTime.now());
    return _routines
        .where((RoutineTask task) => DateTimeUtils.dayOnly(task.date) == today)
        .toList()
      ..sort((RoutineTask a, RoutineTask b) => a.startMinute.compareTo(b.startMinute));
  }

  List<RoutineTask> get upcomingRoutines {
    final List<RoutineTask> items = _routines.where((RoutineTask task) => !task.isCompleted).toList()
      ..sort((RoutineTask a, RoutineTask b) => a.startDateTime.compareTo(b.startDateTime));
    return items.take(6).toList();
  }

  List<Goal> get activeGoals {
    final List<Goal> items = _goals.toList()
      ..sort((Goal a, Goal b) => a.dueDate.compareTo(b.dueDate));
    return items;
  }

  List<StudyNote> get recentNotes => _notes.take(4).toList();

  int get completedRoutineCountToday => todayRoutines.where((RoutineTask task) => task.isCompleted).length;
  int get pendingRoutineCountToday => todayRoutines.where((RoutineTask task) => !task.isCompleted).length;
  int get completedGoalCount => _goals.where((Goal goal) => goal.isCompleted).length;
  double get goalCompletionRate => _goals.isEmpty ? 0 : completedGoalCount / _goals.length;

  Future<void> initialize() async {
    _motivation = motivationService.forDate(DateTime.now());
    _gkFeed = gkService.todayFeed(DateTime.now());
    await _updateStreak();
    await _loadAll();
    await rescheduleMissedTasks();
    await refreshSyncStatus();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _updateStreak() async {
    final DateTime today = DateTimeUtils.dayOnly(DateTime.now());
    final DateTime? lastActive = preferencesService.lastActiveDate == null
        ? null
        : DateTimeUtils.dayOnly(preferencesService.lastActiveDate!);

    if (lastActive == null) {
      _streak = 1;
    } else if (lastActive == today) {
      _streak = preferencesService.streak;
    } else if (today.difference(lastActive).inDays == 1) {
      _streak = preferencesService.streak + 1;
    } else {
      _streak = 1;
    }

    await preferencesService.setStreak(_streak);
    await preferencesService.setLastActiveDate(today);
  }

  Future<void> _loadAll() async {
    _routines = await databaseService.fetchRoutineTasks();
    _goals = await databaseService.fetchGoals();
    _notes = await databaseService.fetchStudyNotes();
  }

  Future<void> refreshSyncStatus({List<ChatMessage> messages = const <ChatMessage>[]}) async {
    _syncStatus = await syncService.sync(
      enabled: preferencesService.cloudSyncEnabled,
      goals: _goals,
      messages: messages,
    );
    notifyListeners();
  }

  Future<void> addRoutine(RoutineTask task) async {
    await databaseService.upsertRoutineTask(task);
    if (task.reminderEnabled) {
      await notificationService.scheduleRoutineReminder(task, preferencesService.userName);
    }
    await _loadAll();
    notifyListeners();
  }

  Future<void> toggleRoutineCompletion(RoutineTask task, bool isCompleted) async {
    final RoutineTask updated = task.copyWith(isCompleted: isCompleted);
    await databaseService.upsertRoutineTask(updated);
    if (isCompleted) {
      await notificationService.cancelRoutineReminder(task.id);
    } else if (updated.reminderEnabled) {
      await notificationService.scheduleRoutineReminder(updated, preferencesService.userName);
    }
    await _loadAll();
    notifyListeners();
  }

  Future<void> deleteRoutine(String id) async {
    await notificationService.cancelRoutineReminder(id);
    await databaseService.deleteRoutineTask(id);
    await _loadAll();
    notifyListeners();
  }

  Future<void> generateSmartRoutine({
    required List<String> subjects,
    required int studyHours,
  }) async {
    final List<RoutineTask> tasks = plannerService.generateSuggestedRoutine(
      date: DateTime.now(),
      subjects: subjects,
      studyHours: studyHours,
    );

    for (final RoutineTask task in tasks) {
      await databaseService.upsertRoutineTask(task);
      await notificationService.scheduleRoutineReminder(task, preferencesService.userName);
    }

    await _loadAll();
    notifyListeners();
  }

  Future<void> rescheduleMissedTasks() async {
    bool changed = false;
    for (final RoutineTask task in _routines) {
      final RoutineTask? updated = plannerService.rescheduleMissedTask(task, DateTime.now());
      if (updated != null) {
        await databaseService.upsertRoutineTask(updated);
        await notificationService.scheduleRoutineReminder(updated, preferencesService.userName);
        changed = true;
      }
    }

    if (changed) {
      await _loadAll();
      notifyListeners();
    }
  }

  Future<void> addGoal(Goal goal) async {
    await databaseService.upsertGoal(goal);
    await notificationService.scheduleGoalReminder(goal, preferencesService.userName);
    await _loadAll();
    notifyListeners();
  }

  Future<void> incrementGoal(Goal goal) async {
    final int completed = min(goal.targetCount, goal.completedCount + 1);
    final Goal updated = goal.copyWith(
      completedCount: completed,
      isCompleted: completed >= goal.targetCount,
    );
    await databaseService.upsertGoal(updated);
    await _loadAll();
    notifyListeners();
  }

  Future<void> deleteGoal(String id) async {
    await databaseService.deleteGoal(id);
    await _loadAll();
    notifyListeners();
  }

  Future<void> addOrUpdateNote(StudyNote note) async {
    await databaseService.upsertStudyNote(note);
    await _loadAll();
    notifyListeners();
  }

  Future<void> deleteNote(String id) async {
    await databaseService.deleteStudyNote(id);
    await _loadAll();
    notifyListeners();
  }
}
