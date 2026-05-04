import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();

  Future<void> initialize() async {
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> speak(String text, String language) async {
    final String voiceLanguage = language == 'bengali' ? 'bn-IN' : 'en-IN';
    await _flutterTts.setLanguage(voiceLanguage);
    await _flutterTts.speak(_plainText(text));
  }

  Future<void> stop() => _flutterTts.stop();

  String _plainText(String text) {
    return text
        .replaceAll('*', '')
        .replaceAll('#', '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
