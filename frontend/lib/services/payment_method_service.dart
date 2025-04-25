import 'dart:convert';

import 'package:firstapp/models/config.dart';
import 'package:firstapp/models/finance/payment_method.dart';
import 'package:firstapp/services/api_helper.dart';
import 'package:firstapp/services/logger_service.dart';
import 'package:http/http.dart' as http;

class PaymentMethodService {
  static final String _baseUrl = AppConfig.baseUrl;
  static final http.Client _client = http.Client();
  static final _logger = LoggerService();
  
  static const _endpoint = '/finance/payment-methods/';
  
  Future<List<PaymentMethod>> fetchPaymentMethods() async {
    try {
      final headers = await ApiHelper.getAuthHeaders();
      final response = await _client.get(
        Uri.parse('$_baseUrl$_endpoint'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((e) => PaymentMethod.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load payment methods');
      }
    } catch (e) {
      _logger.error('Error fetchPaymentMethods: $e');
      rethrow;
    }
  }
}