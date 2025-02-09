import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../routes/index.dart' as route;

class _MockRequestContext extends Mock implements RequestContext {}

void main() {
  group('GET /', () {
    test('responds with a 200 and "Welcome to Dart Frog!".', () async {
      final context = _MockRequestContext();

      final formData = await context.request.formData();
      formData.putIfAbsent('message', () => 'What is Flutter?');

      final response = await route.onRequest(context);
      expect(response.statusCode, equals(HttpStatus.ok));
      expect(
        await response.body(),
        completion(equals('Welcome to Dart Frog!')),
      );
    });
  });
}
