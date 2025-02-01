import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app_creator/domain/entities/improve_code_entity.dart';
import 'package:flutter_app_creator/domain/entities/file_entity.dart';

void main() {
  group('ImproveCodeEntity', () {
    test('コンストラクタからクラスを作成', () {
      final files = [
        FileEntity(
            fileName: 'main.dart',
            content: 'void main() { final String test = "test";}'),
        FileEntity.error('error_file.dart', 'Syntax error'),
      ];

      final entity = ImproveCodeEntity('Fix syntax errors', files);

      expect(entity.pointToFix, 'Fix syntax errors');
      expect(entity.files.length, 2);
      expect(entity.files[0].fileName, 'main.dart');
      expect(
        entity.files[0].content,
        'void main() { final String test = "test";}',
      );
      expect(entity.files[0].errorMessage, isNull);
      expect(entity.files[1].fileName, 'error_file.dart');
      expect(entity.files[1].errorMessage, 'Syntax error');
    });

    test('JSONからクラスを作成し、JSONに変換して元のデータと一致するか確認', () {
      final jsonString = '''
      {
        "pointToFix": "Fix syntax errors",
        "files": [
          {
            "fileName": "main.dart",
            "content": "void main() {}"
          },
          {
            "fileName": "error_file.dart",
            "content": "",
            "errorMessage": "Syntax error"
          }
        ]
      }
      ''';

      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      final entity = ImproveCodeEntity.fromJson(jsonData);

      expect(entity.pointToFix, 'Fix syntax errors');
      expect(entity.files.length, 2);
      expect(entity.files[0].fileName, 'main.dart');
      expect(entity.files[0].content, 'void main() {}');
      expect(entity.files[0].errorMessage, isNull);
      expect(entity.files[1].fileName, 'error_file.dart');
      expect(entity.files[1].errorMessage, 'Syntax error');

      final encodedJson = jsonEncode(entity.toJson());
      final decodedJson = jsonDecode(encodedJson);

      expect(decodedJson, jsonData);
    });

    test('getPromptの出力が期待通りであることを確認', () {
      final files = [
        FileEntity(
            fileName: 'main.dart', content: 'void main() {print("test");}'),
      ];

      final entity = ImproveCodeEntity('Fix syntax errors', files);

      final expectedPrompt = '''
The source for Flutter is available. Please fix the following points.
"Points to fix":"Fix syntax errors",
"Source": "{"pointToFix":"Fix syntax errors","files":[{"fileName":"main.dart","content":"void main() {print(\\"test\\");}"}]}"
  ''';

      expect(entity.getPrompt().trim(), expectedPrompt.trim());
    });
  });
}
