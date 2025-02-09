import 'dart:async';

import 'package:google_generative_ai/google_generative_ai.dart';

import 'abstract_agent.dart';
import 'gemini_agent.dart';

class LlmAgent extends AbstractAgent {
  static final _geminiAgent = GeminiAgent();

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
    final requestMessage = kRequestFormatForLlm
        .replaceFirst(kKeyCommand, command)
        .replaceFirst(kKeyInput, message);

    final response = await _geminiAgent.process(requestMessage);

    return AgentResponse(
      response.message,
      handle: HandleReplies.replace,
    );
  }
}
