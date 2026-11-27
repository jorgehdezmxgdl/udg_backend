import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  static const String _urlDesdeEntorno = String.fromEnvironment('API_URL');

  static String get baseUrl {
    if (_urlDesdeEntorno.isNotEmpty) return _urlDesdeEntorno;

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api';
    }

    return 'http://localhost:3000/api';
  }

  static const Duration timeout = Duration(seconds: 10);
}
