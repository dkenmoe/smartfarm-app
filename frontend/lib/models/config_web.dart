import 'config_base.dart';

class AppConfigImpl extends AppConfigBase {
  @override
  String get devBaseUrl => 'http://localhost:8000/api';
  
  @override
  String get stagingBaseUrl => 'https://staging-api.example.com/api/';
  
  @override
  String get prodBaseUrl => 'https://api.example.com/api/';
  
  @override
  String get environment => 'dev'; // 'dev', 'staging', or 'prod'
}