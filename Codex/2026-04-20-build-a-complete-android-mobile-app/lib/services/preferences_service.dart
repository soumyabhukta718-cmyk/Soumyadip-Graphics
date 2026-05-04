import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  PreferencesService._(this._prefs);

  final SharedPreferences _prefs;

  static Future<PreferencesService> create() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return PreferencesService._(prefs);
  }

  String get userName => _prefs.getString('user_name') ?? 'Friend';
  String get themeMode => _prefs.getString('theme_mode') ?? ThemeMode.system.name;
  String get tutorLanguage => _prefs.getString('tutor_language') ?? 'auto';
  String get apiEndpoint => _prefs.getString('api_endpoint') ?? '';
  String get apiKey => _prefs.getString('api_key') ?? '';
  bool get onlineTutorEnabled => _prefs.getBool('online_tutor_enabled') ?? false;
  bool get cloudSyncEnabled => _prefs.getBool('cloud_sync_enabled') ?? false;
  bool get speakAnswers => _prefs.getBool('speak_answers') ?? false;
  int get streak => _prefs.getInt('study_streak') ?? 1;

  DateTime? get lastActiveDate {
    final String? value = _prefs.getString('last_active_date');
    return value == null ? null : DateTime.tryParse(value);
  }

  Future<void> setUserName(String value) => _prefs.setString('user_name', value.trim());
  Future<void> setThemeMode(String value) => _prefs.setString('theme_mode', value);
  Future<void> setTutorLanguage(String value) => _prefs.setString('tutor_language', value);
  Future<void> setApiEndpoint(String value) => _prefs.setString('api_endpoint', value.trim());
  Future<void> setApiKey(String value) => _prefs.setString('api_key', value.trim());
  Future<void> setOnlineTutorEnabled(bool value) => _prefs.setBool('online_tutor_enabled', value);
  Future<void> setCloudSyncEnabled(bool value) => _prefs.setBool('cloud_sync_enabled', value);
  Future<void> setSpeakAnswers(bool value) => _prefs.setBool('speak_answers', value);
  Future<void> setStreak(int value) => _prefs.setInt('study_streak', value);
  Future<void> setLastActiveDate(DateTime value) => _prefs.setString('last_active_date', value.toIso8601String());
}
