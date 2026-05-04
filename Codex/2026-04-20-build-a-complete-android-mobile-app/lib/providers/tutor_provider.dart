import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/chat_message.dart';
import '../services/tutor_service.dart';
import 'settings_provider.dart';

class TutorProvider extends ChangeNotifier {
  TutorProvider(this._tutorService) {
    unawaited(_initialize());
  }

  final TutorService _tutorService;

  List<ChatMessage> _messages = <ChatMessage>[];
  bool _isLoading = true;
  bool _isSending = false;
  String? _attachedImagePath;

  List<ChatMessage> get messages => List<ChatMessage>.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get attachedImagePath => _attachedImagePath;

  Future<void> _initialize() async {
    _messages = await _tutorService.loadHistory();
    if (_messages.isEmpty) {
      final ChatMessage welcome = ChatMessage(
        id: 'welcome_message',
        sender: 'assistant',
        text: 'I am Shindhu. Ask me any SSC or competitive exam question in English or Bengali, and I will explain it step by step. Offline mode is always available.',
        createdAt: DateTime.now(),
        language: 'english',
        isOffline: true,
      );
      await _tutorService.saveMessage(welcome);
      _messages = <ChatMessage>[welcome];
    }
    _isLoading = false;
    notifyListeners();
  }

  void attachImage(String? path) {
    _attachedImagePath = path;
    notifyListeners();
  }

  Future<void> sendMessage({
    required String text,
    required SettingsProvider settings,
  }) async {
    final String prompt = text.trim();
    if (prompt.isEmpty && (_attachedImagePath == null || _attachedImagePath!.isEmpty)) {
      return;
    }

    final ChatMessage userMessage = ChatMessage(
      id: 'user_${DateTime.now().microsecondsSinceEpoch}',
      sender: 'user',
      text: prompt.isEmpty ? 'Image question attached' : prompt,
      createdAt: DateTime.now(),
      language: settings.tutorLanguage,
      isOffline: true,
      imagePath: _attachedImagePath,
    );

    _messages = <ChatMessage>[..._messages, userMessage];
    _isSending = true;
    notifyListeners();
    await _tutorService.saveMessage(userMessage);

    try {
      final ChatMessage assistantMessage = await _tutorService.generateAssistantMessage(
        prompt: prompt,
        preferredLanguage: settings.tutorLanguage,
        onlineTutorEnabled: settings.onlineTutorEnabled && settings.hasOnlineConfig,
        apiEndpoint: settings.apiEndpoint,
        apiKey: settings.apiKey,
        imagePath: _attachedImagePath,
      );
      _messages = <ChatMessage>[..._messages, assistantMessage];
      await _tutorService.saveMessage(assistantMessage);

      if (settings.speakAnswers) {
        await _tutorService.speak(assistantMessage);
      }
    } finally {
      _isSending = false;
      _attachedImagePath = null;
      notifyListeners();
    }
  }

  Future<void> speak(ChatMessage message) => _tutorService.speak(message);

  Future<void> clearChat() async {
    await _tutorService.clearChat();
    _messages = <ChatMessage>[];
    _isLoading = false;
    notifyListeners();
    await _initialize();
  }
}
