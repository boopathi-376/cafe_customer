import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static void d(String message) {
    if (kDebugMode) debugPrint('[DEBUG] $message');
  }

  static void i(String message) {
    if (kDebugMode) debugPrint('[INFO]  $message');
  }

  static void w(String message) {
    if (kDebugMode) debugPrint('[WARN]  $message');
  }

  static void e(String message, [Object? error, StackTrace? stack]) {
    if (kDebugMode) {
      debugPrint('[ERROR] $message');
      if (error != null) debugPrint('        $error');
      if (stack != null) debugPrint('        $stack');
    }
  }
}
