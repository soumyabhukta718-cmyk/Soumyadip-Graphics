import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/chat_message.dart';
import '../models/goal.dart';
import '../models/pomodoro_session.dart';
import '../models/routine_task.dart';
import '../models/study_note.dart';

class DatabaseService {
  Database? _database;

  Future<void> initialize() async {
    if (_database != null) {
      return;
    }

    final directory = await getApplicationDocumentsDirectory();
    final String dbPath = path.join(directory.path, 'shindhu.db');

    _database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE routines(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            subject TEXT NOT NULL,
            date TEXT NOT NULL,
            start_minute INTEGER NOT NULL,
            end_minute INTEGER NOT NULL,
            is_completed INTEGER NOT NULL,
            reminder_enabled INTEGER NOT NULL,
            notes TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE goals(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            category TEXT NOT NULL,
            timeframe TEXT NOT NULL,
            target_count INTEGER NOT NULL,
            completed_count INTEGER NOT NULL,
            due_date TEXT NOT NULL,
            is_completed INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE pomodoro_sessions(
            id TEXT PRIMARY KEY,
            subject TEXT NOT NULL,
            started_at TEXT NOT NULL,
            focus_minutes INTEGER NOT NULL,
            break_minutes INTEGER NOT NULL,
            completed INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE chat_messages(
            id TEXT PRIMARY KEY,
            sender TEXT NOT NULL,
            text TEXT NOT NULL,
            created_at TEXT NOT NULL,
            language TEXT NOT NULL,
            is_offline INTEGER NOT NULL,
            image_path TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE study_notes(
            id TEXT PRIMARY KEY,
            subject TEXT NOT NULL,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Database get _db {
    final Database? database = _database;
    if (database == null) {
      throw StateError('Database has not been initialized');
    }
    return database;
  }

  Future<List<RoutineTask>> fetchRoutineTasks() async {
    final List<Map<String, Object?>> maps = await _db.query(
      'routines',
      orderBy: 'date ASC, start_minute ASC',
    );
    return maps.map(RoutineTask.fromMap).toList();
  }

  Future<void> upsertRoutineTask(RoutineTask task) async {
    await _db.insert(
      'routines',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteRoutineTask(String id) async {
    await _db.delete('routines', where: 'id = ?', whereArgs: <Object?>[id]);
  }

  Future<List<Goal>> fetchGoals() async {
    final List<Map<String, Object?>> maps = await _db.query(
      'goals',
      orderBy: 'due_date ASC',
    );
    return maps.map(Goal.fromMap).toList();
  }

  Future<void> upsertGoal(Goal goal) async {
    await _db.insert(
      'goals',
      goal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteGoal(String id) async {
    await _db.delete('goals', where: 'id = ?', whereArgs: <Object?>[id]);
  }

  Future<List<PomodoroSession>> fetchPomodoroSessions() async {
    final List<Map<String, Object?>> maps = await _db.query(
      'pomodoro_sessions',
      orderBy: 'started_at DESC',
    );
    return maps.map(PomodoroSession.fromMap).toList();
  }

  Future<void> insertPomodoroSession(PomodoroSession session) async {
    await _db.insert(
      'pomodoro_sessions',
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ChatMessage>> fetchChatMessages() async {
    final List<Map<String, Object?>> maps = await _db.query(
      'chat_messages',
      orderBy: 'created_at ASC',
    );
    return maps.map(ChatMessage.fromMap).toList();
  }

  Future<void> insertChatMessage(ChatMessage message) async {
    await _db.insert(
      'chat_messages',
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> clearChatMessages() async {
    await _db.delete('chat_messages');
  }

  Future<List<StudyNote>> fetchStudyNotes() async {
    final List<Map<String, Object?>> maps = await _db.query(
      'study_notes',
      orderBy: 'updated_at DESC',
    );
    return maps.map(StudyNote.fromMap).toList();
  }

  Future<void> upsertStudyNote(StudyNote note) async {
    await _db.insert(
      'study_notes',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteStudyNote(String id) async {
    await _db.delete('study_notes', where: 'id = ?', whereArgs: <Object?>[id]);
  }
}
