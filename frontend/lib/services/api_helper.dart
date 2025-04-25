import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firstapp/models/config.dart';

class ApiHelper {
  static const _tokenKey = 'access_token';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await _secureStorage.read(key: _tokenKey);
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static String get baseUrl => AppConfig.baseUrl;
}
