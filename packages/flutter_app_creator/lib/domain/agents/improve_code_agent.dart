import 'dart:convert';
import 'dart:io';

import 'package:flutter_app_creator/domain/agents/abstract_agent.dart';
import 'package:flutter_app_creator/domain/agents/llm_agent.dart';
import 'package:flutter_app_creator/domain/entities/improve_code_entity.dart';
import 'package:flutter_app_creator/secret.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:path/path.dart' as path;
import '../entities/file_entity.dart';

class ImproveCodeAgent extends AbstractAgent {
  static const _kPromptForCorrectDart = r'''
The source for Flutter is available. The points for improvement  are included "pointToFix". 
Output is as follows
- Write "%corrected source%" parts in ONE LINE using escape characters
- This is JSON data. Pay particular attention to the closing parentheses.
- Output only this format part.
- Output full code in file
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

  ImproveCodeAgent(
    this._generativeModel, {
    this.dirProject,
  });
  final GenerativeModel _generativeModel;

  late final _improveCodeAgent =
      LlmAgent(_generativeModel, _kPromptForCorrectDart);

  final Directory? dirProject;

  @override
  Future<AgentResponse> process(String message) async {
    assert(
        ImproveCodeEntity.fromJson(jsonDecode(message) as Map<String, dynamic>)
            .pointToFix
            .isNotEmpty);

    final map = jsonDecode(message) as Map<String, dynamic>;
    map['command'] = _kPromptForCorrectDart;

    final improvedCode = await _improveCodeAgent.process(jsonEncode(map));

    final list =
        jsonDecode(_adjustForJson(improvedCode.message)) as List<dynamic>;
    final correctFiles =
        list.map((e) => FileEntity.fromJson(e as Map<String, dynamic>));

    final correctFilesWithRelativePath = dirProject == null
        ? null
        : correctFiles.map((e) => FileEntity(
            fileName: path.relative(e.fileName, from: dirProject!.path),
            content: e.content));

    return AgentResponse(
      jsonEncode((correctFilesWithRelativePath ?? correctFiles).toList()),
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
