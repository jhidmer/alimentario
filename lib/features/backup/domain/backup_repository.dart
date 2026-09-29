abstract interface class BackupRepository {
  Future<String> createBackup();

  Future<void> restoreBackup(String filePath);
}
