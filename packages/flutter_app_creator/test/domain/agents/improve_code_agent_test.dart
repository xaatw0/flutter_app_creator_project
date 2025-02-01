import 'dart:convert';
import 'dart:io';
import 'package:flutter_app_creator/domain/agents/improve_code_agent.dart';
import 'package:flutter_app_creator/domain/entities/file_entity.dart';
import 'package:flutter_app_creator/domain/entities/improve_code_entity.dart';
import 'package:flutter_app_creator/secret.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:path/path.dart' as p;

import 'package:flutter_test/flutter_test.dart';

main() {
  final pathSuccessProject = 'test/domain/agents/test_success_project';

  test('change theme color', () async {
    final directory = Directory(pathSuccessProject);
    expect(directory.existsSync(), true);

    final tempDir = Directory.systemTemp.createTempSync();
    try {
      await _copyDirectory(directory, tempDir);
      final mainDart = File(p.join(tempDir.path, 'lib', 'main.dart'));
      expect(mainDart.existsSync(), true);

      final originalFile = FileEntity(
          fileName: mainDart.path, content: mainDart.readAsStringSync());
      final entity =
          ImproveCodeEntity('change seedColor to lightBlue', [originalFile]);

      final agent = ImproveCodeAgent(
        GenerativeModel(
          model: Secret.llmModelName,
          apiKey: Secret.keyGeminiApiKey,
        ),
        dirProject: tempDir,
      );

      final source = jsonEncode(entity);
      final response = await agent.process(source);
      final resultAsJson = jsonDecode(response.message) as List<dynamic>;
      final result = resultAsJson.map((e) => FileEntity.fromJson(e)).toList();
      expect(result.length, 1);

      expect(originalFile.content.contains('lightBlue'), false);
      expect(originalFile.content.contains('Colors.deepPurple'), true);

      final newFile = result.first;
      expect(newFile.fileName, p.join('lib', 'main.dart'));
      expect(newFile.content.contains('lightBlue'), true);
      expect(newFile.content.contains('Colors.deepPurple'), false);
    } finally {
      tempDir.delete(recursive: true);
    }
  });

  test('add bottom navigation', () async {
    final directory = Directory(pathSuccessProject);
    expect(directory.existsSync(), true);

    final tempDir = Directory.systemTemp.createTempSync();
    try {
      await _copyDirectory(directory, tempDir);
      final mainDart = File(p.join(tempDir.path, 'lib', 'main.dart'));
      expect(mainDart.existsSync(), true);

      final originalFile = FileEntity(
          fileName: mainDart.path, content: mainDart.readAsStringSync());
      final entity = ImproveCodeEntity(
          'add bottom navigation with three buttons', [originalFile]);

      final agent = ImproveCodeAgent(
        GenerativeModel(
          model: Secret.llmModelName,
          apiKey: Secret.keyGeminiApiKey,
        ),
        dirProject: tempDir,
      );

      final source = jsonEncode(entity);
      final response = await agent.process(source);
      final resultAsJson = jsonDecode(response.message) as List<dynamic>;
      final result = resultAsJson.map((e) => FileEntity.fromJson(e)).toList();
      expect(result.length, 1);
    } finally {
      tempDir.delete(recursive: true);
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
