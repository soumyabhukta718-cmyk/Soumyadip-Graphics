import '../models/chat_message.dart';
import '../models/goal.dart';

class SyncService {
  Future<String> sync({
    required bool enabled,
    required List<Goal> goals,
    required List<ChatMessage> messages,
  }) async {
    if (!enabled) {
      return 'Local-only mode active. Your data stays on this device.';
    }

    return 'Cloud sync toggle is on, but Firebase is not configured yet. Local data is safe and ready for future sync.';
  }
}
