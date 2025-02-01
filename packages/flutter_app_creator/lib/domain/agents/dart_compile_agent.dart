import 'dart:convert';
import 'dart:io';
import 'package:flutter_app_creator/domain/agents/error_finder_agent.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:path/path.dart' as path;

import '../../secret.dart';
import '../entities/build_result_entity.dart';
import '../entities/file_entity.dart';
import 'abstract_agent.dart';
import 'correct_dart_agent.dart';
import 'file_input_agent.dart';
import 'file_output_agent.dart';
import 'llm_agent.dart';

class DartCompileAgent extends AbstractAgent {
  static const _kPromptForCorrectDart = r'''
Here are Flutter code files with build errors. Build error is included "buildErrorMessage". Fix them so that they can be built.
- Write "%corrected source%" parts in ONE LINE using escape characters
- This is JSON data. Pay particular attention to the closing parentheses.
- Output only this format part
- output only files you corrected
- Use the output format below:
[
  {
    "fileName": "%file_name1%",
    "content": "%corrected source%",
  },
    ...continue if more files
  {
    "fileName": "%file_name2%",
    "content": "%corrected source%",
  }
]
''';
  DartCompileAgent(
    this._generativeModel,
    this.dirProject, {
    this.countTryCompile = 10,
  });

  final GenerativeModel _generativeModel;
  final Directory dirProject;
  final int countTryCompile;

  late final _correctDartAgent =
      LlmAgent(_generativeModel, _kPromptForCorrectDart);

  late final _fileOutputAgent = FileOutputAgent(dirOutput: dirProject);

  static const _kMessageWithNoIssue = 'No issues found!';

  @override
  Future<AgentResponse> process(String message) async {
    final errorFinderAgent = ErrorFinderAgent(dirProject);

    final correctDartAgent = CorrectDartAgent(
      dirProject,
      GenerativeModel(
        model: Secret.llmModelName,
        apiKey: Secret.keyGeminiApiKey,
      ),
    );

    for (int counter = 0; counter < countTryCompile; counter++) {
      final responseAboutError = await errorFinderAgent.process(message);
      final errorEntity =
          BuildResultEntity.fromJson(jsonDecode(responseAboutError.message));

      if (!errorEntity.hasError) {
        return _buildSuccess(dirProject);
      }

      // Fix the files based on the files and build errors
      final responseForCorrectDart =
          await correctDartAgent.process(responseAboutError.message);

      // Fix the files
      await _fileOutputAgent.input(responseForCorrectDart.message);

      await Future.delayed(const Duration(milliseconds: 5));
    }
    return AgentResponse('cannot build', handle: HandleReplies.replace);
  }

  Future<AgentResponse> _buildSuccess(Directory directory) {
    final filePaths = directory
        .listSync(recursive: true)
        .where((e) => e.path.endsWith('.dart'))
        .map((e) => path.relative(e.path, from: directory.path))
        .map((e) => FileEntity.name(e))
        .toList();
    final fileInputAgent = FileInputAgent(directory: directory);
    return fileInputAgent.process(jsonEncode(filePaths));
  }
}
