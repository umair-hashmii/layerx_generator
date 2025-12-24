part of layerx_generator;

// ========================= REPOSITORIES =========================

extension _RepositoriesPart on LayerXGenerator {
  Future<void> _createRepositoryFiles(String appDirPath) async {
    final authRepoDir = Directory(path.join(appDirPath, 'repository', 'auth_repo'));
    final apiRepoDir = Directory(path.join(appDirPath, 'repository', 'apis'));

    await File(path.join(authRepoDir.path, 'auth_repository.dart')).writeAsString('''
... your same auth_repository.dart content ...
''');

    await File(path.join(apiRepoDir.path, 'data_repository.dart')).writeAsString('''
... your same data_repository.dart content ...
''');

    stdout.writeln('Created repository files.');
  }
}
