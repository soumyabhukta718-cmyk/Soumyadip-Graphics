import 'dart:convert';
import 'dart:io';

import '../models/chat_message.dart';
import 'database_service.dart';
import 'offline_ai_service.dart';
import 'online_ai_service.dart';
import 'tts_service.dart';

class TutorService {
  TutorService({
    required this.databaseService,
    required this.offlineAiService,
    required this.onlineAiService,
    required this.ttsService,
  });

  final DatabaseService databaseService;
  final OfflineAiService offlineAiService;
  final OnlineAiService onlineAiService;
  final TtsService ttsService;

  Future<List<ChatMessage>> loadHistory() => databaseService.fetchChatMessages();

  Future<void> saveMessage(ChatMessage message) => databaseService.insertChatMessage(message);

  Future<void> clearChat() => databaseService.clearChatMessages();

  Future<ChatMessage> generateAssistantMessage({
    required String prompt,
    required String preferredLanguage,
    required bool onlineTutorEnabled,
    required String apiEndpoint,
    required String apiKey,
    String? imagePath,
  }) async {
    String? onlineReply;

    if (onlineTutorEnabled) {
      try {
        onlineReply = await onlineAiService.generateReply(
          endpoint: apiEndpoint,
          apiKey: apiKey,
          prompt: prompt,
          language: preferredLanguage,
          imageBase64: await _imageAsBase64(imagePath),
        );
      } catch (_) {
        onlineReply = null;
      }
    }

    final String reply = onlineReply ??
        offlineAiService.generateReply(
          prompt: prompt,
          preferredLanguage: preferredLanguage,
          imagePath: imagePath,
        );

    return ChatMessage(
      id: 'assistant_${DateTime.now().microsecondsSinceEpoch}',
      sender: 'assistant',
      text: reply,
      createdAt: DateTime.now(),
      language: preferredLanguage,
      isOffline: onlineReply == null,
      imagePath: null,
    );
  }

  Future<void> speak(ChatMessage message) {
    return ttsService.speak(message.text, message.language);
  }

  Future<String?> _imageAsBase64(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) {
      return null;
    }

    final File file = File(imagePath);
    if (!await file.exists()) {
      return null;
    }

    final List<int> bytes = await file.readAsBytes();
    return bytes.isEmpty ? null : base64Encode(bytes);
  }
}
