import 'dart:convert';

import 'package:flutter_app_creator/domain/entities/file_entity.dart';

class ImproveCodeEntity {
  const ImproveCodeEntity(this.pointToFix, this.files);

  final String pointToFix;
  final List<FileEntity> files;

  factory ImproveCodeEntity.fromJson(Map<String, dynamic> json) {
    return ImproveCodeEntity(
      json['pointToFix'] as String,
      (json['files'] as List<dynamic>)
          .map((fileJson) =>
              FileEntity.fromJson(fileJson as Map<String, dynamic>))
          .toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'pointToFix': pointToFix,
      'files': files.map((file) => file.toJson()).toList(),
    };
  }

  String getPrompt() => '''
The source for Flutter is available. Please fix the following points.
"Points to fix":"$pointToFix",
"Source": "${jsonEncode(this)}"
  ''';
}
