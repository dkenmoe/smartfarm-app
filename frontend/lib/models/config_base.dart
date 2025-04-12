abstract class AppConfigBase {
  String get devBaseUrl;
  String get stagingBaseUrl;
  String get prodBaseUrl;
  String get environment;
  
  String get baseUrl {
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