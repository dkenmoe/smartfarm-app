import 'dart:convert';
import 'package:firstapp/models/acquisition_record.dart';
import 'package:firstapp/models/config.dart';
import 'package:firstapp/services/api_helper.dart';
import 'package:firstapp/services/logger_service.dart';
import 'package:http/http.dart' as http;

class AcquisitionService {
  static final String _baseUrl = AppConfig.baseUrl;
  static final http.Client _client = http.Client();
  static final _logger = LoggerService();

  static const String _acquisitionRecordsEndpoint =
      '/animals/acquisition_records/';

  static Future<List<AcquisitionRecord>> fetchAcquisitions() async {
    try {
      final response = await _client.get(
        Uri.parse('${_baseUrl}${_acquisitionRecordsEndpoint}'),
        headers: await ApiHelper.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        return responseData
            .map((json) => AcquisitionRecord.fromJson(json))
            .toList();
      } else {
        _logger.error('Error fetching acquisitions: $response');
        return [];
      }
    } catch (e) {
      _logger.error('Error fetching acquisitions: $e');
      return [];
    }
  }

  static Future<bool> createAcquisition(AcquisitionRecord acquisition) async {
    try {
      final headers = await ApiHelper.getAuthHeaders();
      final response = await _client.post(
        Uri.parse('$_baseUrl$_acquisitionRecordsEndpoint'),
        headers: headers,
        body: json.encode(acquisition.toJson()),
      );
      return response.statusCode == 201;
    } catch (e) {
      _logger.error('Erreur createExpense: $e');
      return false;
    }
  }

  // Update an existing acquisition record
  static Future<bool> updateAcquisition(AcquisitionRecord acquisition) async {
    try {
      final response = await _client.put(
        Uri.parse(
          '${_baseUrl}/${_acquisitionRecordsEndpoint}${acquisition.id}/',
        ),
        headers: await ApiHelper.getAuthHeaders(),
        body: json.encode(acquisition.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      _logger.error('Error updating acquisition: $e');
      return false;
    }
  }

  // Delete an acquisition record
  static Future<bool> deleteAcquisition(int id) async {
    try {
      final response = await _client.delete(
        Uri.parse('${_baseUrl}/${_acquisitionRecordsEndpoint}$id/'),
        headers: await ApiHelper.getAuthHeaders(),
      );
      return response.statusCode == 204;
    } catch (e) {
      _logger.error('Error deleting acquisition: $e');
      return false;
    }
  }
}
