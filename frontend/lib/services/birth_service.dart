import 'dart:convert';
import 'package:firstapp/models/birth_record.dart';
import 'package:firstapp/models/config.dart';
import 'package:firstapp/services/api_helper.dart';
import 'package:firstapp/services/logger_service.dart';
import 'package:http/http.dart' as http;

class BirthService {
  static final String _baseUrl = AppConfig.baseUrl;
  static final http.Client _client = http.Client();
  static final _logger = LoggerService();

  static const String _birthRecordsEndpoint = '/animals/birth-records/';

 static Future<List<BirthRecord>> fetchBirthRecords() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl$_birthRecordsEndpoint'),
        headers: await ApiHelper.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => BirthRecord.fromJson(item)).toList();
      } else {
        _logger.error('Failed to load birth records: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      _logger.error('Error fetching birth records: $e');
      return [];
    }
  }

  static Future<bool> registerBirth(BirthRecord birthRecord) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl$_birthRecordsEndpoint'),
        headers: await ApiHelper.getAuthHeaders(),
        body: json.encode(birthRecord.toJson()),
      );
      
      return response.statusCode == 201;
    } catch (e) {
      _logger.error('Error registering birth: $e');
      return false;
    }
  }

  static Future<bool> updateBirthRecord(BirthRecord birthRecord) async {
    try {
      final response = await _client.put(
        Uri.parse('$_baseUrl$_birthRecordsEndpoint$birthRecord.id'),
        headers: await ApiHelper.getAuthHeaders(),
        body: json.encode(birthRecord.toJson()),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      _logger.error('Error updating birth record: $e');
      return false;
    }
  }

  static Future<bool> deleteBirthRecord(int id) async {
    try {
      final response = await _client.delete(
        Uri.parse('$_baseUrl$_birthRecordsEndpoint$id'),
        headers: await ApiHelper.getAuthHeaders(),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      _logger.error('Error deleting birth record: $e');
      return false;
    }
  }
}
