import 'dart:convert';
import 'dart:io';

import 'package:flutter_app_creator/domain/agents/dart_compile_agent.dart';
import 'package:flutter_app_creator/domain/agents/file_input_agent.dart';
import 'package:flutter_app_creator/domain/agents/file_output_agent.dart';
import 'package:flutter_app_creator/domain/agents/improve_code_agent.dart';
import 'package:flutter_app_creator/domain/entities/file_entity.dart';
import 'package:flutter_app_creator/domain/entities/improve_code_entity.dart';
import 'package:flutter_app_creator/domain/modules/create_copy_project.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'package:path/path.dart' as p;

class GenerateCode {
  const GenerateCode(this._generativeModel, this._dirProject);

  final GenerativeModel _generativeModel;

  final Directory _dirProject;

  Future<void> generate(String requestForImprove) async {
    final copyProject = CreateCopyProject(_dirProject);
    final dirTemp = await copyProject.execute();

    // TEMPディレクトリのtargetをビルドする
    final dartCompileAgent = DartCompileAgent(_generativeModel, dirTemp);
    await dartCompileAgent.process('');

    final mainDart = File(p.join(dirTemp.path, 'lib', 'main.dart'));

    final improveCodeAgent =
        ImproveCodeAgent(_generativeModel, dirProject: dirTemp);

    final improveCodeEntity = ImproveCodeEntity(requestForImprove, [
      FileEntity(fileName: mainDart.path, content: mainDart.readAsStringSync())
    ]);

    final responseImproveCode =
        await improveCodeAgent.process(jsonEncode(improveCodeEntity));

    print(responseImproveCode.message);
    final fileOutputAgent = FileOutputAgent(dirOutput: dirTemp);

    await fileOutputAgent.process(responseImproveCode.message);

    final responseCompile = await dartCompileAgent.process('');
    if (responseCompile.message == 'cannot build') {
      throw Exception('cannot build');
    }

    final fileOutputAgentForProject = FileOutputAgent(dirOutput: _dirProject);
    fileOutputAgentForProject.process(responseCompile.message);
  }

  Future<List<FileEntity>> extractProductCode(Directory projectDirectory) {
    return projectDirectory
        .list(recursive: true)
        .where((file) {
          if (file.statSync().type == FileSystemEntityType.directory) {
            return false;
          }

          final relativePath =
              p.relative(file.path, from: projectDirectory.path);
          return relativePath == 'pubspec.yaml' ||
              (relativePath.startsWith('lib') &&
                  relativePath.endsWith('.dart'));
        })
        .where((file) => p.basename(file.path).split('.').length == 2)
        .map((e) => FileEntity.name(e.path))
        .toList();
  }
}
