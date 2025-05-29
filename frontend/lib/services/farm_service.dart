import 'dart:convert';
import 'package:firstapp/models/farm.dart';
import 'package:firstapp/models/config.dart';
import 'package:firstapp/services/api_helper.dart';
import 'package:http/http.dart' as http;

class FarmService {
  static final String _baseUrl = AppConfig.baseUrl;
  static final http.Client _client = http.Client();

  static Future<List<Farm>> fetchUserFarms() async {
    final headers = await ApiHelper.getAuthHeaders();
    final uri = Uri.parse('$_baseUrl/auth/user-farms/');
    final response = await _client.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Farm.fromJson(json)).toList();
    } else {
      throw Exception('Erreur chargement des fermes');
    }
  }
}
