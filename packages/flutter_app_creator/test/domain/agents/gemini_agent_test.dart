import 'package:flutter_app_creator/domain/agents/gemini_agent.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('access', () async {
    final url = Uri.parse(
        'https://geminiapi-477639193964.asia-northeast2.run.app/check_connect');
    final response = await http.get(url);
    expect(response.body, 'Working!');
  });

  test('post', () async {
    final url =
        Uri.parse('https://geminiapi-477639193964.asia-northeast2.run.app');
    final response =
        await http.post(url, body: {'message': '1+1=? Reply only number'});
    expect(response.body.trim(), '2');
  });

  test('agent', () async {
    final agent = GeminiAgent();
    final response = await agent.process('Say only Hello!');
    expect(response.message.trim(), 'Hello!');
  });
}
