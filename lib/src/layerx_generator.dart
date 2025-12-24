/// A Flutter package that auto-generates the LayerX directory structure for scalable MVVM projects.
///
/// The `layerx_generator` package simplifies the setup of a Flutter project by generating
/// a clean MVVM (Model-View-ViewModel) directory structure under `lib/app/`. It includes
/// pre-configured utilities for HTTP requests, local storage, location services, logging,
/// and API response handling, all integrated with GetX for state management, navigation,
/// and dependency injection.
library layerx_generator;

import 'dart:io';
import 'package:path/path.dart' as path;

part 'parts/config_part.dart';
part 'parts/mvvm_part.dart';
part 'parts/models_part.dart';
part 'parts/services_part.dart';
part 'parts/notifications_part.dart';
part 'parts/repositories_part.dart';
part 'parts/app_part.dart';
part 'parts/https_calls_part.dart';

/// Generates the LayerX directory structure for a Flutter project.
///
/// ✅ Refined generator rules:
/// - No file references a class that isn't generated.
/// - All routes point to a generated view.
/// - Repositories only call methods that exist in services.
/// - Body models that use File include `dart:io`.
/// - Pubspec auto-updated to include required dependencies (so `flutter run` works without errors).
class LayerXGenerator {
  final String projectPath;

  LayerXGenerator(this.projectPath);

  Future<void> generate() async {
    try {
      final projectDir = Directory(projectPath);
      if (!await projectDir.exists()) {
        throw Exception('Project directory does not exist: $projectPath');
      }

      final libDir = Directory(path.join(projectPath, 'lib'));
      if (!await libDir.exists()) {
        throw Exception('Not a Flutter project (missing lib/): $projectPath');
      }

      final appDir = Directory(path.join(projectPath, 'lib', 'app'));
      await appDir.create(recursive: true);

      final directories = [
        'config',
        'mvvm/model/body_model',
        'mvvm/model/response_model',
        'mvvm/model/api_response_model',
        'mvvm/view/splash',
        'mvvm/view/login',
        'mvvm/view_model/splash',
        'mvvm/view_model/login',
        'repository/auth_repo',
        'repository/firebase',
        'repository/local_db',
        'repository/apis',
        'services',
        'services/notifications',
        'widgets',
      ];

      for (final dir in directories) {
        final fullPath = path.join(appDir.path, dir);
        await Directory(fullPath).create(recursive: true);
        stdout.writeln('Created directory: $fullPath');
      }

      await _createConfigFiles(appDir.path);
      await _createMVVMSkeleton(appDir.path);
      await _createModelFiles(appDir.path);
      await _createServiceFiles(appDir.path);
      await _createNotificationFiles(appDir.path);
      await _createRepositoryFiles(appDir.path);
      await _createAppWidgetFile(projectPath);
      await _updateMainFile(projectPath);

      stdout.writeln('✅ LayerX structure generated successfully!');
    } catch (e) {
      stderr.writeln('❌ Error generating LayerX structure: $e');
      rethrow;
    }
  }
}
