import 'dart:io';

import 'package:args/args.dart';
import 'package:layerx_generator/layerx_generator.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(
      'path',
      abbr: 'p',
      help: 'Path to the Flutter project directory',
      defaultsTo: '.',
    );

  final results = parser.parse(arguments);
  final projectPath = results['path'] as String;

  print('Generating LayerX directory structure in: $projectPath');
  final generator = LayerXGenerator(projectPath);

  try {
    await generator.generate();
    print('LayerX directory structure generated successfully!');
  } catch (e) {
    print('Failed to generate LayerX structure: $e');
    exit(1);
  }
}
