import 'dart:convert';
import 'package:firstapp/models/config.dart';
import 'package:firstapp/models/finance/expense.dart';
import 'package:firstapp/services/api_helper.dart';
import 'package:firstapp/services/logger_service.dart';
import 'package:http/http.dart' as http;

class ExpenseService {
  static final String _baseUrl = AppConfig.baseUrl;
  static final http.Client _client = http.Client();
  static final _logger = LoggerService();

  static const _expensesEndpoint = '/finance/expenses/';

  Future<List<Expense>> fetchExpenses() async {
    try {
      final headers = await ApiHelper.getAuthHeaders();
      final response = await _client.get(
        Uri.parse('$_baseUrl$_expensesEndpoint'),
        headers: headers,
      );

      if (response.statusCode == 200) {

          return (json.decode(response.body) as List)
            .map((item) => Expense.fromJson(item))
            .toList();
        // final List<dynamic> jsonList = json.decode(response.body);
        // return jsonList.map((e) => Expense.fromJson(e)).toList();
      } else {
        throw Exception('Erreur de chargement des dépenses');
      }
    } catch (e) {
      _logger.error('Erreur fetchExpenses: $e');
      rethrow;
    }
  }

  Future<bool> createExpense(Expense expense) async {
    try {
      final headers = await ApiHelper.getAuthHeaders();
      final response = await _client.post(
        Uri.parse('$_baseUrl$_expensesEndpoint'),
        headers: headers,
        body: json.encode(expense.toJson()),
      );
      return response.statusCode == 201;
    } catch (e) {
      _logger.error('Erreur createExpense: $e');
      return false;
    }
  }

  Future<bool> updateExpense(Expense expense) async {
    try {
      final headers = await ApiHelper.getAuthHeaders();
      final response = await _client.put(
        Uri.parse('$_baseUrl$_expensesEndpoint${expense.id}/'),
        headers: headers,
        body: json.encode(expense.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      _logger.error('Erreur updateExpense: $e');
      return false;
    }
  }

  Future<bool> deleteExpense(int id) async {
    try {
      final headers = await ApiHelper.getAuthHeaders();
      final response = await _client.delete(
        Uri.parse('$_baseUrl$_expensesEndpoint$id/'),
        headers: headers,
      );
      return response.statusCode == 204;
    } catch (e) {
      _logger.error('Erreur deleteExpense: $e');
      return false;
    }
  }
}
