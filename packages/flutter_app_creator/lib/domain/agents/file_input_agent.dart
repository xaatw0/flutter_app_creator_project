import 'dart:convert';
import 'dart:io';

import '../entities/file_entity.dart';
import 'abstract_agent.dart';

import 'package:path/path.dart' as p;

class FileInputAgent extends AbstractAgent {
  FileInputAgent({this.directory});

  final Directory? directory;

  @override
  Future<AgentResponse> process(String message) async {
    final jsonData = jsonDecode(message) as List<dynamic>;
    final paths =
        jsonData.map((e) => FileEntity.fromJson(e)).map((e) => e.fileName);

    final files = paths.map((path) => _processFile(path.trim()));
    final fileJson = jsonEncode(await Future.wait(files));
    return AgentResponse(fileJson, handle: HandleReplies.replace);
  }

  Future<FileEntity> _processFile(String path) async {
    final absolutePath =
        p.isAbsolute(path) ? path : p.join(directory?.path ?? '', path);
    final relativePath =
        p.isRelative(path) ? path : p.relative(path, from: directory?.path);

    final file = File(absolutePath);
    if (!file.existsSync()) {
      return FileEntity.error(path, 'not found');
    }
    try {
      return FileEntity.file(relativePath, file.readAsStringSync());
    } on IOException catch (ex) {
      return FileEntity.error(path, ex.toString());
    }
  }
}
