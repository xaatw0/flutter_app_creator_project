import 'dart:io';

import 'package:flutter_app_creator/domain/agents/agent.dart';
import 'package:flutter_app_creator/domain/entities/file_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

class ReadFilesAgent implements IAgent<List<FileEntity>, List<FileEntity>> {
  const ReadFilesAgent(this.dirProject);
  final Directory dirProject;

  @override
  Future<AResponse<List<FileEntity>>> execute(
      ARequest<List<FileEntity>> request) async {
    final fileNames = request().map((e) => e.fileName);

    return AResponse(
      fileNames
          .map((e) => FileEntity(
              fileName: e,
              content:
                  File(p.join(dirProject.absolute.path, e)).readAsStringSync()))
          .toList(),
    );
  }
}

void main() {
  final pathSuccessProject =
      p.join('test', 'domain', 'agents', 'test_success_project');
  final dirProject = Directory(pathSuccessProject);

  test('プロジェクトの存在確認', () {
    expect(dirProject.existsSync(), true);
  });

  test('ファイル読み込み', () async {
    final file1 = p.join('pubspec.yaml');
    final file2 = p.join('lib', 'main.dart');

    final request =
        ARequest([file1, file2].map((e) => FileEntity.name(e)).toList());

    final agent = ReadFilesAgent(dirProject);
    final response = await agent.execute(request);
    final files = response();
    expect(files.length, 2);

    expect(files[0].fileName, 'pubspec.yaml');
    expect(files[0].content.contains('sdk: flutter'), true);

    expect(files[1].fileName.endsWith('main.dart'), true);
    expect(files[1].content.contains('Flutter Demo Home Page'), true);
  });
}
