part of layerx_generator;

// ========================= SERVICES =========================

extension _ServicesPart on LayerXGenerator {
  Future<void> _createServiceFiles(String appDirPath) async {
    final servicesDir = Directory(path.join(appDirPath, 'services'));

    await File(path.join(servicesDir.path, 'logger_service.dart')).writeAsString('''
... your same logger_service.dart content ...
''');

    await File(path.join(servicesDir.path, 'shared_preferences_service.dart')).writeAsString('''
... your same shared_preferences_service.dart content ...
''');

    await File(path.join(servicesDir.path, 'global_variables.dart')).writeAsString('''
... your same global_variables.dart content ...
''');

    await File(path.join(servicesDir.path, 'json_extractor.dart')).writeAsString('''
... your same json_extractor.dart content ...
''');

    await File(path.join(servicesDir.path, 'location_service.dart')).writeAsString('''
... your same location_service.dart content ...
''');

    await File(path.join(servicesDir.path, 'api_response_handler.dart')).writeAsString('''
... your same api_response_handler.dart content ...
''');

    await File(path.join(servicesDir.path, 'https_calls.dart'))
        .writeAsString(_httpsCallsContent());

    stdout.writeln('Created service files.');
  }
}
