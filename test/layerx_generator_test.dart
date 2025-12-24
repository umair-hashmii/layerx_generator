import 'dart:io';
import 'package:layerx_generator/layerx_generator.dart';
import 'package:test/test.dart';

void main() {
  group('LayerXGenerator', () {
    test('generates directory structure', () async {
      final tempDir = Directory('test_temp');
      await tempDir.create();

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

      // Clean up
      await tempDir.delete(recursive: true);
    });
  });
}
