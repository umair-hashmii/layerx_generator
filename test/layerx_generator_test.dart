import 'dart:io';
import 'package:layerx_generator/layerx_generator.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as p;

void main() {
  group('LayerXGenerator', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = Directory('test_temp');
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
      await tempDir.create();

      // Setup minimal Flutter project structure
      await Directory(p.join(tempDir.path, 'lib')).create();
      await File(p.join(tempDir.path, 'pubspec.yaml')).writeAsString('''
name: test_project
dependencies:
  flutter:
    sdk: flutter
''');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('generates directory structure', () async {
      final generator = LayerXGenerator(tempDir.path);
      await generator.generate();

      // Check if key directories exist
      expect(Directory('${tempDir.path}/lib/app/config').existsSync(), true);
      expect(
        Directory('${tempDir.path}/lib/app/mvvm/model').existsSync(),
        true,
      );
      expect(
        Directory('${tempDir.path}/lib/app/repository').existsSync(),
        true,
      );
      expect(Directory('${tempDir.path}/lib/app/services').existsSync(), true);

      // Check if placeholder files exist
      expect(
        File('${tempDir.path}/lib/app/config/app_colors.dart').existsSync(),
        true,
      );
      expect(
        File(
          '${tempDir.path}/lib/app/mvvm/model/api_response_model/api_response.dart',
        ).existsSync(),
        true,
      );
    });
  });
}
