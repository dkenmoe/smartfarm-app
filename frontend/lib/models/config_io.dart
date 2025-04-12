import 'dart:io';
import 'config_base.dart';

class AppConfigImpl extends AppConfigBase {
  @override
  String get devBaseUrl => Platform.isAndroid ? 'http://10.0.2.2:8000/api' : 'http://127.0.0.1:8000/api';
  
  @override
  String get stagingBaseUrl => 'https://staging-api.example.com/api/';
  
  @override
  String get prodBaseUrl => 'https://api.example.com/api/';
  
  @override
  String get environment => 'dev'; // 'dev', 'staging', or 'prod'
}