import 'dart:async';

import 'package:google_generative_ai/google_generative_ai.dart';

import 'abstract_agent.dart';

class LlmAgent extends AbstractAgent {
  LlmAgent(
    this._generativeModel,
    this.command,
  );

  final GenerativeModel _generativeModel;
  final String command;

  static const kKeyCommand = '%command%';
  static const kKeyInput = '%input%';
  static const kRequestFormatForLlm =
      '{"command":"$kKeyCommand","input":"$kKeyInput"}';

  static const kMessageWhenGotNoMessage = '[No message from AI]';

  @override
  Future<AgentResponse> process(String message) async {
    final content = [Content.text(message)];
    final response = await _generativeModel.generateContent(content);

    return AgentResponse(
      response.text ?? kMessageWhenGotNoMessage,
      handle: HandleReplies.replace,
    );
  }
}
