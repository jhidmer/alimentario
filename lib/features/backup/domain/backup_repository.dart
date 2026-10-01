abstract interface class BackupRepository {
  Future<String> createBackup({String? destinationDirectory});

  Future<void> restoreBackup(String filePath);
}
