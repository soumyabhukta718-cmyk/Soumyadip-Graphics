import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/app_identity.dart';

class OnlineAiService {
  Future<String?> generateReply({
    required String endpoint,
    required String apiKey,
    required String prompt,
    required String language,
    String? imageBase64,
  }) async {
    if (endpoint.trim().isEmpty || apiKey.trim().isEmpty) {
      return null;
    }

    final Uri? uri = Uri.tryParse(endpoint);
    if (uri == null) {
      return null;
    }

    
    final http.Response response = await http
        .post(
          uri,
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
            'x-api-key': apiKey,
          },
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return null;
    }

    final dynamic data = jsonDecode(response.body);
    return _extractText(data);
  }

  String? _extractText(dynamic data) {
    if (data is String) {
      return data;
    }

    if (data is List) {
      for (final dynamic item in data) {
        final String? value = _extractText(item);
        if (value != null && value.trim().isNotEmpty) {
          return value;
        }
      }
    }

    if (data is Map<String, dynamic>) {
      for (final String key in <String>[
        'reply',
        'answer',
        'content',
        'output_text',
        'text',
      ]) {
        final dynamic value = data[key];
        final String? extracted = _extractText(value);
        if (extracted != null && extracted.trim().isNotEmpty) {
          return extracted;
        }
      }

      final dynamic choices = data['choices'];
      final String? choiceText = _extractText(choices);
      if (choiceText != null && choiceText.trim().isNotEmpty) {
        return choiceText;
      }

      final dynamic output = data['output'];
      final String? outputText = _extractText(output);
      if (outputText != null && outputText.trim().isNotEmpty) {
        return outputText;
      }

      final dynamic message = data['message'];
      final String? messageText = _extractText(message);
      if (messageText != null && messageText.trim().isNotEmpty) {
        return messageText;
      }
    }

    return null;
  }
}
