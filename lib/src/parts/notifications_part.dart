part of layerx_generator;

// ========================= NOTIFICATIONS =========================

extension _NotificationsPart on LayerXGenerator {
  Future<void> _createNotificationFiles(String appDirPath) async {
    final notifDir = Directory(path.join(appDirPath, 'services', 'notifications'));
    await notifDir.create(recursive: true);

    await File(path.join(notifDir.path, 'notification_permissions.dart'))
        .writeAsString(_notificationPermissionsContent());

    await File(path.join(notifDir.path, 'notification_service.dart'))
        .writeAsString(_notificationServiceContent());

    await File(path.join(notifDir.path, 'server_key.dart'))
        .writeAsString(_serverKeyContent());

    stdout.writeln('✅ Created notification files in services/notifications/');
  }

  String _notificationPermissionsContent() => r'''
... your same notification_permissions.dart string ...
''';

  String _notificationServiceContent() => r'''
... your same notification_service.dart string ...
''';

  String _serverKeyContent() => r'''
... your same server_key.dart string ...
''';
}
