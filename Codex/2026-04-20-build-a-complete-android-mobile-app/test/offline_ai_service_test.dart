import 'package:flutter_test/flutter_test.dart';
import 'package:shindhu_study_companion/services/offline_ai_service.dart';

void main() {
  test('offline AI remembers the app identity', () {
    final OfflineAiService service = OfflineAiService();
    final String reply = service.generateReply(
      prompt: 'Who built you?',
      preferredLanguage: 'english',
    );

    expect(reply, contains('Soumyadip Bhukta'));
    expect(reply, contains('Debashrita Goswami'));
  });
}
