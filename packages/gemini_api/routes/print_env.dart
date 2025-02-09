import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  final key1 = Platform.environment['KEY1'];
  final key2 = Platform.environment['KEY2'];
  final key3 = Platform.environment['GEMINI_API_KEY'];
  return Future.value(Response(
    body: 'Working! KEY1: $key1, KEY2: $key2, KEY3: $key3',
  ));
}
