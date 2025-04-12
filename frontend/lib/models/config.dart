import 'config_base.dart';
import 'config_io.dart' if (dart.library.html) 'config_web.dart';

class AppConfig {
  static final AppConfigBase _config = AppConfigImpl();
  
  static String get devBaseUrl => _config.devBaseUrl;
  static String get stagingBaseUrl => _config.stagingBaseUrl;
  static String get prodBaseUrl => _config.prodBaseUrl;
  static String get environment => _config.environment;
  static String get baseUrl => _config.baseUrl;
}