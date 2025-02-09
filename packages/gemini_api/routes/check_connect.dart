import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  return Future.value(Response(
    body: 'Working!',
  ));
}
