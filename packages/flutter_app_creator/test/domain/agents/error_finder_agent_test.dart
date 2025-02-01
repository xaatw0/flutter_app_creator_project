import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:flutter_app_creator/domain/agents/error_finder_agent.dart';
import 'package:flutter_app_creator/domain/entities/build_result_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final pathSuccessProject = 'test/domain/agents/test_success_project';

  test('success', () async {
    final directory = Directory(pathSuccessProject);
    expect(directory.existsSync(), true);

    final tempDir = Directory.systemTemp.createTempSync();
    try {
      await _copyDirectory(directory, tempDir);
      final mainDart = File(p.join(tempDir.path, 'lib', 'main.dart'));
      expect(mainDart.existsSync(), true);

      final agent = ErrorFinderAgent(tempDir);
      final result = await agent.process('');
      final entity = BuildResultEntity.fromJson(jsonDecode(result.message));
      expect(entity.hasError, false);
      expect(entity.errorMessage.isEmpty, true);
    } finally {
      tempDir.delete(recursive: true);
    }
  });

  test('error code', () async {
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

      final agent = ErrorFinderAgent(tempDir);
      final result = await agent.process('');
      final entity = BuildResultEntity.fromJson(jsonDecode(result.message));
      expect(entity.hasError, true);
      expect(entity.errorMessage.isEmpty, false);
      expect(
          entity.errorMessage.trim(),
          r'''
error - The function 'runAppX' isn't defined - lib\main.dart:4:3 - undefined_function
error - The method 'MaterialAppX' isn't defined for the type 'MyApp' - lib\main.dart:13:12 - undefined_method
      '''
              .trim());
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
