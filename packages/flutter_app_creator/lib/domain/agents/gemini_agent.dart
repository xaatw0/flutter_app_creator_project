import 'package:flutter_app_creator/domain/agents/abstract_agent.dart';
import 'package:http/http.dart' as http;

class GeminiAgent extends AbstractAgent {
  final _url =
      Uri.parse('https://geminiapi-477639193964.asia-northeast2.run.app');
  @override
  Future<AgentResponse> process(String message) async {
    final response = await http.post(_url, body: {'message': message});

    return AgentResponse(response.body, handle: HandleReplies.replace);
  }
}
