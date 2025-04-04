// logger_service.dart
import 'package:logger/logger.dart';

class LoggerService {
  // Singleton pattern
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;
  LoggerService._internal();

  // Configure logger once
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      // ignore: deprecated_member_use
      printTime: true,
    ),
    // Optional: different LogFilter for different environments
    // filter: ProductionFilter(), // Use in production
    // filter: DevelopmentFilter(), // Use in development
  );

  // Log level methods
  void debug(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  void info(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  void warning(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  void error(String message, {dynamic error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  void wtf(String message, {dynamic error, StackTrace? stackTrace}) {
    // ignore: deprecated_member_use
    _logger.wtf(message, error: error, stackTrace: stackTrace);
  }
}