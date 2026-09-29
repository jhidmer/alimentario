import 'dart:developer' as developer;

enum LogLevel { debug, info, warning, error }

abstract final class AppLogger {
  static void debug(String message) => _write(LogLevel.debug, message);
  static void info(String message) => _write(LogLevel.info, message);
  static void warning(String message) => _write(LogLevel.warning, message);
  static void error(String message, [Object? error, StackTrace? stackTrace]) => _write(LogLevel.error, message, error, stackTrace);

  static void _write(LogLevel level, String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(message, name: 'diario_alimentario.${level.name}', error: error, stackTrace: stackTrace);
  }
}
