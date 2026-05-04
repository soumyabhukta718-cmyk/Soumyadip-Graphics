import 'package:flutter/material.dart';

import '../services/preferences_service.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._preferencesService)
      : _userName = _preferencesService.userName,
        _themeMode = _themeModeFromString(_preferencesService.themeMode),
        _tutorLanguage = _preferencesService.tutorLanguage,
        _apiEndpoint = _preferencesService.apiEndpoint,
        _apiKey = _preferencesService.apiKey,
        _onlineTutorEnabled = _preferencesService.onlineTutorEnabled,
        _cloudSyncEnabled = _preferencesService.cloudSyncEnabled,
        _speakAnswers = _preferencesService.speakAnswers;

  final PreferencesService _preferencesService;

  String _userName;
  ThemeMode _themeMode;
  String _tutorLanguage;
  String _apiEndpoint;
  String _apiKey;
  bool _onlineTutorEnabled;
  bool _cloudSyncEnabled;
  bool _speakAnswers;

  String get userName => _userName;
  ThemeMode get themeMode => _themeMode;
  String get tutorLanguage => _tutorLanguage;
  String get apiEndpoint => _apiEndpoint;
  String get apiKey => _apiKey;
  bool get onlineTutorEnabled => _onlineTutorEnabled;
  bool get cloudSyncEnabled => _cloudSyncEnabled;
  bool get speakAnswers => _speakAnswers;

  bool get hasOnlineConfig => _apiEndpoint.trim().isNotEmpty && _apiKey.trim().isNotEmpty;

  Future<void> updateUserName(String value) async {
    _userName = value.trim().isEmpty ? 'Friend' : value.trim();
    await _preferencesService.setUserName(_userName);
    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode value) async {
    _themeMode = value;
    await _preferencesService.setThemeMode(value.name);
    notifyListeners();
  }

  Future<void> updateTutorLanguage(String value) async {
    _tutorLanguage = value;
    await _preferencesService.setTutorLanguage(value);
    notifyListeners();
  }

  Future<void> updateApiEndpoint(String value) async {
    _apiEndpoint = value.trim();
    await _preferencesService.setApiEndpoint(_apiEndpoint);
    notifyListeners();
  }

  Future<void> updateApiKey(String value) async {
    _apiKey = value.trim();
    await _preferencesService.setApiKey(_apiKey);
    notifyListeners();
  }

  Future<void> updateOnlineTutorEnabled(bool value) async {
    _onlineTutorEnabled = value;
    await _preferencesService.setOnlineTutorEnabled(value);
    notifyListeners();
  }

  Future<void> updateCloudSyncEnabled(bool value) async {
    _cloudSyncEnabled = value;
    await _preferencesService.setCloudSyncEnabled(value);
    notifyListeners();
  }

  Future<void> updateSpeakAnswers(bool value) async {
    _speakAnswers = value;
    await _preferencesService.setSpeakAnswers(value);
    notifyListeners();
  }

  static ThemeMode _themeModeFromString(String value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }
}
