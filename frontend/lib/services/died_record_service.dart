import 'dart:convert';
import 'package:firstapp/models/config.dart';
import 'package:firstapp/models/died_record.dart';
import 'package:firstapp/services/api_helper.dart';
import 'package:firstapp/services/logger_service.dart';
import 'package:http/http.dart' as http;

class DiedRecordService {
  static final String _baseUrl = AppConfig.baseUrl;
  static final http.Client _client = http.Client();
  static final _logger = LoggerService();

  static const String _diedRecordsEndpoint = '/animals/died-records/';

  static Future<List<DiedRecord>> fetchDiedRecords() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_diedRecordsEndpoint'),
        headers: await ApiHelper.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => DiedRecord.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load died records: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching died records: $e');
    }
  }

  static Future<bool> createDiedRecord(DiedRecord record) async {
    try {
      final headers = await ApiHelper.getAuthHeaders();
      final response = await _client.post(
        Uri.parse('$_baseUrl$_diedRecordsEndpoint'),
        headers: headers,
        body: json.encode(record.toJson()),
      );

      if (response.statusCode == 201) {
        return true;
      }
      _logger.error("Registration error: ${response.body}");
      return false;
    } catch (e) {
      print('Error registering death: $e');
      return false;
    }
  }

  static Future<bool> updateDiedRecord(DiedRecord expense) async {
    try {
      final headers = await ApiHelper.getAuthHeaders();
      final response = await _client.put(
        Uri.parse('$_baseUrl$_diedRecordsEndpoint${expense.id}/'),
        headers: headers,
        body: json.encode(expense.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      _logger.error('Erreur updateExpense: $e');
      return false;
    }
  }

  static Future<bool> deleteDiedRecord(int id) async {
    try {
      final headers = await ApiHelper.getAuthHeaders();
      final response = await _client.delete(
        Uri.parse('$_baseUrl$_diedRecordsEndpoint$id/'),
        headers: headers,
      );
      return response.statusCode == 204;
    } catch (e) {
      _logger.error('Erreur deleteExpense: $e');
      return false;
    }
  }
}
