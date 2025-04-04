import 'dart:io';

class AppConfig {

  static String devBaseUrl = Platform.isAndroid ? 'http://10.0.2.2:8000/api':'http://127.0.0.1:8000/api';
  static const String stagingBaseUrl = 'https://staging-api.example.com/api/';
  static const String prodBaseUrl = 'https://api.example.com/api/';
  
  // Set this based on your build environment
  static const String environment = 'dev'; // 'dev', 'staging', or 'prod'
  
  static String get baseUrl {
    switch (environment) {
      case 'prod':
        return prodBaseUrl;
      case 'staging':
        return stagingBaseUrl;
      case 'dev':
      default:
        return devBaseUrl;
    }
  }
}