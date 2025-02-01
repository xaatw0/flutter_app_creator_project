import 'dart:convert';
import 'dart:io';
import 'package:flutter_app_creator/domain/entities/file_entity.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:path/path.dart' as path;

import '../value_objects/llm_model.dart';
import 'abstract_agent.dart';
import 'llm_agent.dart';

class FileOutputFormatterAgent extends AbstractAgent {
  static const kKeyFileName = 'fileName';
  static const kKeyContent = 'content';
  static const kPrompt = '''[
      {"$kKeyFileName":"%$kKeyFileName%","$kKeyContent":"%$kKeyContent%"},
      ....
      {"$kKeyFileName":"%$kKeyFileName%","$kKeyContent":"%$kKeyContent%"}
  ]
  Please extract the part to be output as a file from the "input" data and rewrite them in the format above. Please only output the part in the format above.
''';

  FileOutputFormatterAgent(this._generativeModel, {this.directory})
      : llmAgent = LlmAgent(_generativeModel, kPrompt);

  final GenerativeModel _generativeModel;
  final LlmAgent llmAgent;
  final Directory? directory;

  @override
  Future<AgentResponse> process(String message) async {
    /*
    final filesJson = jsonDecode(message) as List<dynamic>;
    final filesEntity = filesJson.map((e) => FileEntity.fromJson(e)).toList();

    for (var fileData in filesEntity) {
      final fileName = fileData[kKeyFileName];
      fileNames.add(fileName);

      final file = File(path.join(directory?.path ?? '', fileName));
      file.writeAsString(fileData[kKeyContent]);
    }

    final json = jsonEncode(fileNames);
    return AgentResponse(json, handle: HandleReplies.replace);*/
    throw UnsupportedError('message');
  }
}
