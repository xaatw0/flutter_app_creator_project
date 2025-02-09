import 'dart:io';

import 'package:google_generative_ai/google_generative_ai.dart';

class LlmModel {
  static const _kLlmModelName = 'gemini-1.5-flash';
  static const _kMessageWhenGotNoMessage = '[No message from AI]';
  static const _kKeyWebApi = 'GEMINI_API_KEY';

  final _generativeModel = GenerativeModel(
    model: _kLlmModelName,
    apiKey: Platform.environment[_kKeyWebApi]!,
  );

  Future<String> sendMessage(String message) async {
    final content = [Content.text(message)];
    final response = await _generativeModel.generateContent(content);
    return response.text ?? _kMessageWhenGotNoMessage;
  }
}
