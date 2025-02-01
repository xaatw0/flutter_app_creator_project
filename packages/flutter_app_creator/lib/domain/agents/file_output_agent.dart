import 'dart:convert';
import 'dart:io';
import 'package:flutter_app_creator/domain/entities/file_entity.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:path/path.dart' as p;

import '../value_objects/llm_model.dart';
import 'abstract_agent.dart';
import 'llm_agent.dart';

class FileOutputAgent extends AbstractAgent {
  FileOutputAgent({this.dirOutput});

  final Directory? dirOutput;

  @override
  Future<AgentResponse> process(String message) async {
    final filesJson = jsonDecode(message) as List<dynamic>;
    final filesEntity = filesJson.map((e) => FileEntity.fromJson(e)).toList();

    final result = <FileEntity>[];

    for (var fileData in filesEntity) {
      final fullPath = p.join(dirOutput?.path ?? '', fileData.fileName);

      try {
        File(fullPath).writeAsStringSync(fileData.content);
        result.add(FileEntity.name(fileData.fileName));
      } catch (ex) {
        result.add(FileEntity.error(fileData.fileName, ex.toString()));
      }
    }

    final json = jsonEncode(result);
    return AgentResponse(json, handle: HandleReplies.replace);
  }
}
