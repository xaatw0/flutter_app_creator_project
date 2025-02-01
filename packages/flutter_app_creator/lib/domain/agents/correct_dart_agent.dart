import 'dart:convert';
import 'dart:io';

import 'package:flutter_app_creator/domain/agents/abstract_agent.dart';
import 'package:flutter_app_creator/domain/entities/build_result_entity.dart';
import 'package:flutter_app_creator/domain/value_objects/llm_model.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../entities/file_entity.dart';
import 'llm_agent.dart';

class CorrectDartAgent extends AbstractAgent {
  static const _kPromptForCorrectDart = r'''
Here are Flutter code files with build errors. Build error message is included "buildErrorMessage". Fix them so that they can be built.
- Write "%corrected source%" parts in ONE LINE using escape characters
- This is JSON data. Pay particular attention to the closing parentheses.
- Output only this format part.
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

  CorrectDartAgent(this.dirProject, this._generativeModel);
  final Directory dirProject;
  final GenerativeModel _generativeModel;

  late final _correctDartAgent =
      LlmAgent(_generativeModel, _kPromptForCorrectDart);
  @override
  Future<AgentResponse> process(String message) async {
    final errorMessage =
        BuildResultEntity.fromJson(jsonDecode(message) as Map<String, dynamic>);

    final files = dirProject
        .listSync(recursive: true)
        .where((e) => e.path.endsWith('.dart'))
        .map((file) =>
            FileEntity.file(file.path, File(file.path).readAsStringSync()));

    final jsonDataForCorrectError = {
      'command': _kPromptForCorrectDart,
      'buildErrorMessage': errorMessage.errorMessage,
      'files': jsonEncode(files.toList()),
    };

    final correctDataSource =
        await _correctDartAgent.process(jsonEncode(jsonDataForCorrectError));
    print('message: ${_adjustForJson(correctDataSource.message)}');
    final list =
        jsonDecode(_adjustForJson(correctDataSource.message)) as List<dynamic>;
    final correctFiles = list
        .map((e) => FileEntity.fromJson(e as Map<String, dynamic>))
        .toList();

    return AgentResponse(
      jsonEncode(correctFiles),
      handle: HandleReplies.replace,
    );
  }

  String _adjustForJson(String source) {
    final jsonBeginMark = '```json';
    final jsonEndMark = '```';

    if (source.startsWith(jsonBeginMark)) {
      source = source.replaceFirst(jsonBeginMark, '');
    }
    if (source.trim().endsWith(jsonEndMark)) {
      source = source.replaceFirst(
        jsonEndMark,
        '',
        source.length - jsonEndMark.length - 3,
      );
    }
    return source;
  }
}
