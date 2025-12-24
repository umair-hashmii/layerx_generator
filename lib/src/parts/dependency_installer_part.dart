import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

class DependencyInstaller {
  static const Map<String, String> layerXDeps = {
    'get': '^4.7.3',
    'flutter_screenutil': '^5.9.3',
    'http': '^1.6.0',
    'shared_preferences': '^2.5.4',
    'logger': '^2.6.2',
    'google_fonts': '^6.3.3',
    'intl': '^0.20.2',
    'timezone': '^0.10.0',
    'flutter_local_notifications': '^19.5.0',
    'permission_handler': 'any',
    'flutter_timezone': '^5.0.1',
  };


  static Future<void> install(String projectPath) async {
    final pubspec = File(p.join(projectPath, 'pubspec.yaml'));
    if (!pubspec.existsSync()) {
      throw Exception('pubspec.yaml not found');
    }

    final content = pubspec.readAsStringSync();
    final yaml = loadYaml(content);

    final existingDeps = <String>{};

    if (yaml is YamlMap && yaml['dependencies'] is YamlMap) {
      for (final key in (yaml['dependencies'] as YamlMap).keys) {
        existingDeps.add(key.toString());
      }
    }

    final buffer = StringBuffer();
    buffer.writeln('\n# LayerX auto-added dependencies');

    bool shouldAppend = false;

    for (final entry in layerXDeps.entries) {
      if (!existingDeps.contains(entry.key)) {
        buffer.writeln('  ${entry.key}: ${entry.value}');
        shouldAppend = true;
      }
    }

    if (!shouldAppend) return;

    final lines = content.split('\n');
    final newLines = <String>[];

    bool inDependencies = false;
    bool inserted = false;

    for (int i = 0; i < lines.length; i++) {
      newLines.add(lines[i]);

      if (lines[i].trim() == 'dependencies:') {
        inDependencies = true;
        continue;
      }

      if (inDependencies &&
          i + 1 < lines.length &&
          !lines[i + 1].startsWith(' ')) {
        newLines.add(buffer.toString());
        inserted = true;
        inDependencies = false;
      }
    }

    if (!inserted && inDependencies) {
      newLines.add(buffer.toString());
    }

    pubspec.writeAsStringSync(newLines.join('\n'));
  }
}
