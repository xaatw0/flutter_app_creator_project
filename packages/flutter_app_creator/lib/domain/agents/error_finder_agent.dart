import 'dart:convert';
import 'dart:io';

import 'package:flutter_app_creator/domain/agents/abstract_agent.dart';
import 'package:flutter_app_creator/domain/entities/build_result_entity.dart';

import 'package:process_run/shell.dart';

class ErrorFinderAgent extends AbstractAgent {
  ErrorFinderAgent(this.dirProject);
  final Directory dirProject;

  late var shell = Shell(workingDirectory: dirProject.path);
  static const _kMessageWithNoIssue = 'No issues found!';

  @override
  Future<AgentResponse> process(String message) async {
    await shell.run('flutter pub get');

    final ProcessResult processResult;
    try {
      processResult = (await shell.run('flutter analyze')).first;
    } on ShellException catch (e) {
      final entity = BuildResultEntity.fromBuildResult(e.result!.outText);
      return AgentResponse(jsonEncode(entity), handle: HandleReplies.replace);
    }

    final message = processResult.outText;
    final isSuccess = message.contains(_kMessageWithNoIssue);
    final entity =
        BuildResultEntity(!isSuccess, errorMessage: isSuccess ? '' : message);

    return AgentResponse(jsonEncode(entity), handle: HandleReplies.replace);
  }
}
