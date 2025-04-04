import 'dart:convert';
import 'package:firstapp/models/config.dart';
import 'package:firstapp/services/logger_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String _accessTokenKey = 'access_token';

  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  // Logger instance
  final LoggerService _logger = LoggerService();

  AuthService._internal();

  // Create a single instance of FlutterSecureStorage
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<bool> login(String username, String password) async {
    try {
      var baseUrl = AppConfig.baseUrl;
      var response = await http.post(        
        Uri.parse('$baseUrl/auth/login/'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        await _secureStorage.write(key: _accessTokenKey, value: data['access']);
        _logger.info('User logged in successfully');
        return true;
      }

      _logger.warning('Login failed with status code: ${response.statusCode}');
      return false;
    } catch (e) {
      _logger.error('Login error', error: e);
      return false;
    }
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: _accessTokenKey);
    _logger.info('User logged out');
  }

  Future<bool> isAuthenticated() async {
    final token = await _secureStorage.read(key: _accessTokenKey);
    final isAuth = token != null;
    _logger.debug('Authentication check: $isAuth');
    return isAuth;
  }

  Future<String?> getToken() async {
    final token = await _secureStorage.read(key: _accessTokenKey);
    if (token == null) {
      _logger.debug('Token requested but not found');
    } else {
      _logger.debug('Token retrieved successfully');
    }
    return token;
  }
}
