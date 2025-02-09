import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:gemini_api/llm_modell.dart';

Future<Response> onRequest(RequestContext context) async {
  try {
    return switch (context.request.method) {
      HttpMethod.post => _onPost(context),
      _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
    };
  } catch (e) {
    return Future.value(Response(
      statusCode: HttpStatus.internalServerError,
      body: e.toString(),
    ));
  }
}

Future<Response> _onPost(RequestContext context) async {
  final formData = await context.request.formData();
  final message = formData.fields['message'];
  if (message == null) {
    return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'message': 'No "message" field'});
  }
  final llmModel = LlmModel();
  final response = await llmModel.sendMessage(message);

  return Response(body: response);
}
