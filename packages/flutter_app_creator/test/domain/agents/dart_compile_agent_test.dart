import 'dart:convert';
import 'dart:io';
import 'package:flutter_app_creator/domain/agents/dart_compile_agent.dart';
import 'package:flutter_app_creator/domain/entities/file_entity.dart';
import 'package:flutter_app_creator/secret.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:path/path.dart' as p;

import 'package:flutter_test/flutter_test.dart';

main() {
  final pathSuccessProject = 'test/domain/agents/test_success_project';

  test('correct error', () async {
    final directory = Directory(pathSuccessProject);
    expect(directory.existsSync(), true);

    final tempDir = Directory.systemTemp.createTempSync();
    try {
      await _copyDirectory(directory, tempDir);
      final mainDart = File(p.join(tempDir.path, 'lib', 'main.dart'));
      expect(mainDart.existsSync(), true);

      final source = mainDart
          .readAsStringSync()
          .replaceFirst('runApp', 'runAppX')
          .replaceFirst('MaterialApp', 'MaterialAppX');
      mainDart.writeAsStringSync(source);
      expect(mainDart.readAsStringSync().contains('runAppX'), true);

      final model = GenerativeModel(
          model: Secret.llmModelName, apiKey: Secret.keyGeminiApiKey);

      final agent = DartCompileAgent(model, tempDir);
      final responseCompile = await agent.process('');
      expect(mainDart.readAsStringSync().contains('runAppX'), false);
      final files = jsonDecode(responseCompile.message) as List<dynamic>;

      expect(files.length, 1);

      final fileMain = FileEntity.fromJson(files.first as Map<String, dynamic>);
      expect(fileMain.fileName, p.join('lib', 'main.dart'));
    } finally {
      tempDir.deleteSync(recursive: true);
    }
  });
}

Future<void> _copyDirectory(Directory from, Directory to) async {
  await to.create(recursive: true);
  await for (final file in from.list(recursive: true)) {
    final copyTo = p.join(to.path, p.relative(file.path, from: from.path));
    if (file is Directory) {
      await Directory(copyTo).create(recursive: true);
    } else if (file is File) {
      await File(file.path).copy(copyTo);
    } else if (file is Link) {
      await Link(copyTo).create(await file.target(), recursive: true);
    }
  }
}
