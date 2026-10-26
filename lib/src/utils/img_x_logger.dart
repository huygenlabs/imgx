import 'dart:developer' as developer;

/// Minimal logger used by ImgX, built only on the Dart SDK.
///
/// Output goes through [developer.log], which the framework routes to the
/// debug console and DevTools in debug builds, and to logcat / the Apple
/// unified log in release builds. It can also be filtered by the `imgx` log
/// name in observatories that support it.
///
/// Created by lovepreetsingh on 26,October,2026
class ImgXLogger {
  const ImgXLogger._();

  static const String _name = 'imgx';

  /// Level reported to `dart:developer` for errors (SEVERE).
  static const int _errorLevel = 1000;

  /// Logs [message] at error level, optionally with the [error] and
  /// [stackTrace] that caused it.
  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: _name,
      level: _errorLevel,
      error: error,
      stackTrace: stackTrace ?? StackTrace.current,
    );
  }
}
