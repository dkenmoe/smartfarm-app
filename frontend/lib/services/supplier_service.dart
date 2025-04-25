import 'dart:convert';

import 'package:firstapp/models/config.dart';
import 'package:firstapp/models/finance/supplier.dart';
import 'package:firstapp/services/api_helper.dart';
import 'package:firstapp/services/logger_service.dart';
import 'package:http/http.dart' as http;

class SupplierService {
  static final String _baseUrl = AppConfig.baseUrl;
  static final http.Client _client = http.Client();
  static final _logger = LoggerService();
  
  static const _endpoint = '/finance/suppliers/';
  
  Future<List<Supplier>> fetchSuppliers() async {
    try {
      final headers = await ApiHelper.getAuthHeaders();
      final response = await _client.get(
        Uri.parse('$_baseUrl$_endpoint'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((e) => Supplier.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load suppliers');
      }
    } catch (e) {
      _logger.error('Error fetchSuppliers: $e');
      rethrow;
    }
  }
}