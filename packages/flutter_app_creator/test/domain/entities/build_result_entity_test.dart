import 'package:flutter_app_creator/domain/entities/build_result_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BuildResultEntity Tests', () {
    test('toJson should return correct map', () {
      // Arrange
      final entity =
          BuildResultEntity(true, errorMessage: 'Compilation failed');

      // Act
      final json = entity.toJson();

      // Assert
      expect(json, {
        'hasError': true,
        'errorMessage': 'Compilation failed',
      });
    });

    test('fromJson should create correct instance', () {
      // Arrange
      final json = {'hasError': true, 'errorMessage': 'Compilation failed'};

      // Act
      final entity = BuildResultEntity.fromJson(json);

      // Assert
      expect(entity.hasError, true);
      expect(entity.errorMessage, 'Compilation failed');
    });

    test('Default errorMessage should be an empty string', () {
      // Arrange
      final entity = BuildResultEntity(false);

      // Act & Assert
      expect(entity.errorMessage, '');
    });

    test('toJson and fromJson should work together', () {
      // Arrange
      final originalEntity = BuildResultEntity(false, errorMessage: 'All good');

      // Act
      final json = originalEntity.toJson();
      final recreatedEntity = BuildResultEntity.fromJson(json);

      // Assert
      expect(recreatedEntity.hasError, originalEntity.hasError);
      expect(recreatedEntity.errorMessage, originalEntity.errorMessage);
    });
  });

  group('domain', () {
    test('generate from compile result', () {
      final buildResult = r'''
Shell: Analyzing 8ef421bc...                                           
Shell: 
Shell:   error - The function 'runAppX' isn't defined - lib\main.dart:4:3 - undefined_function
Shell:   error - The method 'MaterialAppX' isn't defined for the type 'MyApp' - lib\main.dart:13:12 - undefined_method
Shell: 
Shell: 2 issues found. (ran in 0.8s)
      ''';

      final result = BuildResultEntity.fromBuildResult(buildResult);
      expect(result.hasError, true);
      expect(
          result.errorMessage.trim(),
          r'''
Shell:   error - The function 'runAppX' isn't defined - lib\main.dart:4:3 - undefined_function
Shell:   error - The method 'MaterialAppX' isn't defined for the type 'MyApp' - lib\main.dart:13:12 - undefined_method
      '''
              .trim());
    });
  });
}
